---
layout: post
title: Decrypting Flume Water Monitor Traffic
date: "2026-07-26 18:00:00 -0700"
tags:
  - hardware
  - wifi
  - home
  - automation
  - flume
  - water
  - utilities
---
In my [previous post](/2024/12/11/diving-into-flume-water-monitor), I tore
apart a Flume water monitor and traced its communication path from the sensor,
through the bridge, and up to Flume's cloud MQTT server. I identified the
encryption library (LibHydrogen), extracted a firmware ELF, and even managed to
coerce the bridge into sending plaintext by corrupting the public key in flash.
But that approach was destructive; the bridge couldn't complete its handshake
with Flume's server, so real data stopped flowing.

Since then, I've found a much better approach: read the device's secret key
from flash (a non-destructive, read-only operation), then sit between the
bridge and Flume's server decrypting traffic in both directions while
forwarding it untouched. The bridge stays happy, the Flume app keeps working,
and I get to see all my water usage data locally.

<!--more-->

## Why I Thought This Would Be Harder

The firmware contains a full LibHydrogen Noise N key exchange implementation.
In the disassembly, `hydro_kx_n_1` lives at `0x4023382c` (client side) and
`flume_kx_init_client` at `0x40234550` calls it with `PSK=NULL` and the
server's public key loaded from flash. These functions have real
cross-references to session key storage locations. Everything pointed to the
bridge negotiating ephemeral session keys with Flume's server, which would have
made passive decryption impossible without writing a custom key pair to flash
and implementing the full key exchange in the relay.

From the previous investigation, when I invalidated the magic prefix on the key
storage area, Flume's server responded with error 174: "Phydro crypto key
exchange function failed." That error message, combined with the key exchange
code in the firmware, made it seem certain that session keys were in play.

But when I actually captured live traffic and tried decrypting with just the
static device key, everything decrypted cleanly. No session keys involved.

The Noise N code exists in the firmware but isn't active for normal MQTT
traffic. It might be used for OTA updates, or a provisioning step that only
runs once, or it may be a remnant of an older protocol version. I don't know.
What matters is that in practice, the bridge encrypts and decrypts all messages
with the same static 32-byte key stored in flash.

## The Encryption Parameters

The bridge encrypts all MQTT payloads using LibHydrogen's `secretbox`
construction with a single symmetric key for both directions. That key lives at
a fixed flash address (`0x3f9010`) and can be read without modifying the
device.

The encryption parameters are straightforward:

- Algorithm: `hydro_secretbox` (LibHydrogen)
- Key: 32 bytes at flash address `0x3f9010`
- Context: the ASCII string `12345678`
- Message ID: `0` (constant for all messages)

With these parameters known, any message can be decrypted.

## Reading the Key

The bridge's ESP8266 has labeled UART pins on the board. By connecting a 3.3V
USB-to-serial adapter and pulling GPIO0 low during power-on, the chip enters
UART download mode. From there, `esptool` can read arbitrary flash regions:

```bash
esptool read_flash 0x3f9010 0x20 device_sk.bin
xxd -p -c 32 device_sk.bin
```

This prints a 64-character hex string, the device secret key. The bridge
doesn't need to be reflashed or modified in any way. Remove the GPIO0 jumper,
reassemble, and the bridge boots normally.

## The Relay Architecture

The bridge connects to `mqtt.prod.flumetech.com` on port 1883 (plain TCP, no
TLS). By redirecting this traffic at the network layer, either with DNS
overrides or destination NAT on the router, the bridge connects to a local relay
instead.

The relay is a Node.js process running an [Aedes](https://github.com/moscajs/aedes)
MQTT broker. When the bridge connects, the relay:

1. Accepts the bridge's MQTT CONNECT (capturing its client ID and credentials)
2. Opens its own connection to `mqtt.prod.flumetech.com` using those same credentials
3. Mirrors all subscriptions from the bridge to the upstream server
4. Forwards every message in both directions, decrypting each payload for logging

Because the relay forwards encrypted payloads byte-for-byte, neither the bridge
nor Flume's server can tell anything has changed. The bridge continues its
normal operation and the Flume mobile app works as usual.

I built [libhydrogen-wasm](https://github.com/stevecrozz/libhydrogen-wasm),
an Emscripten compilation of LibHydrogen to WebAssembly, specifically to handle
the decryption in JavaScript.

## What the Traffic Reveals

Messages travel on MQTT topics following the pattern
`2/<type>/12/<device_id>/<counter>`. The bridge subscribes to
`responses/<device_id>/#` for each device (one for the bridge itself, one for
the sensor) to receive downstream messages from Flume.

### Connection Sequence

When the bridge powers on, the first messages tell a clear story:

```json
[
  {"timestamp": 1785105156, "type": 32768},
  {"timestamp": 1785105163, "type": 16384}
]
```

These are type 4 (event) messages. The event codes are powers of 2; `32768`,
`16384`, and `256` have all been observed. Their exact meanings are unknown,
but the timing suggests they correspond to startup state transitions (the
`32768` appears first, `16384` follows about seven seconds later, and `256`
arrives shortly after that).

The bridge then sends a log message confirming the connection:

```json
[{"timestamp": 1785105163, "type": 1024, "level": 4, "message": "reconnected"}]
```

And once the sensor is linked, it reports a SHA hash, possibly a firmware
commit, but that's unconfirmed:

```json
[{"timestamp": 1785105263, "type": 1, "level": 4, "message": "152eb0f620a1be2baa74742a55395599a0c5c107"}]
```

### Water Flow Data

The most interesting messages are type 1, published on the sensor's device
topic. These contain timestamped values that increase monotonically:

```json
[
  {"timestamp": 1785104646, "value": 3828906},
  {"timestamp": 1785104676, "value": 3828907},
  {"timestamp": 1785104691, "value": 3828908},
  {"timestamp": 1785104716, "value": 3828909},
  {"timestamp": 1785104731, "value": 3828910},
  {"timestamp": 1785104767, "value": 3828911}
]
```

The `value` field appears to be a cumulative counter, likely magnetometer
pulses from the water meter's rotating element, though that's an inference
based on the hardware. At times when water use is low, the counter increments
by 1 every
15–30 seconds. At times when water use is higher, it increments faster:

```json
[
  {"timestamp": 1785105201, "value": 3828929},
  {"timestamp": 1785105206, "value": 3828932},
  {"timestamp": 1785105211, "value": 3828936},
  {"timestamp": 1785105216, "value": 3828941},
  {"timestamp": 1785105221, "value": 3828943}
]
```

Here the counter jumps by 3–5 every 5 seconds. The relationship between
counter increments and actual water volume is unknown; calibrating against a
container of known volume would establish the conversion factor.

### Sensor Status

Type 2 messages on the sensor topic carry a collection of bitmask-keyed
fields:

```json
[{
  "1": 2, "2": 17, "4": 18, "8": 7,
  "16": -79, "32": 3252, "128": 0,
  "1024": 24, "2048": 7, "4096": 0, "8192": 1,
  "16384": 3214, "131072": 3530, "262144": 50,
  "timestamp": 1785105287
}]
```

Some fields are identifiable by their value ranges:

| Key | Likely meaning | Reasoning |
|-----|----------------|-----------|
| 16 | RSSI (dBm) | -79 is a typical radio signal strength |
| 32 | Battery (mV) | 3252 → 3.252V, reasonable for lithium |
| 16384 | Reference voltage? | 3214 mV, close to battery |

### Bridge Status

The bridge reports its own type 2 status less frequently:

```json
[{"4": 28496, "32": -87, "128": 13, "256": 10, "512": -60, "timestamp": 1785105496}]
```

| Key | Likely meaning | Reasoning |
|-----|----------------|-----------|
| 32 | Sensor RSSI (dBm) | -87, the 915 MHz radio link |
| 512 | WiFi RSSI (dBm) | -60, typical for indoor WiFi |
| 4 | Uptime or free heap | 28496, could be seconds or bytes |

### Heartbeats

Flume's server sends periodic heartbeats (type 4, downstream) which the bridge
echoes back verbatim as type 6:

```json
{
  "timestamp": 1785105391038968,
  "heartbeat": {"id": "c4fc411648ca757e2f5210aa9af441f7", "seq": 1}
}
```

The timestamp appears to be microsecond-precision. The sequence number
increments with each heartbeat; I've observed them arriving roughly every 10
minutes.

## What's Next

The relay works and the data is flowing. Some open threads:

- **Pulse-to-volume calibration.** Running a known volume of water while
  watching the counter will determine the conversion factor.
- **Local dashboarding.** With decoded flow data available, piping it into
  InfluxDB or Home Assistant would provide local-only water monitoring
  independent of Flume's cloud.
- **Bitmask field identification.** Longer observation across different
  conditions (low battery, weak signal, temperature changes) should reveal
  what the remaining status fields encode.
- **Reporting cadence.** Flow data arrives in batches roughly every 30
  seconds. Flume's handshake response may control this; a crafted response
  might increase resolution.

The full relay implementation is available at
[github.com/stevecrozz/flumewatch](https://github.com/stevecrozz/flumewatch).
