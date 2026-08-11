---
layout: post
title: Decrypting Flume Water Monitor Traffic
date: "2026-08-11 13:44:40 -0700"
tags:
  - hardware
  - wifi
  - home
  - automation
  - flume
  - water
  - utilities
---
In my [previous post](/2024/12/diving-into-flume-water-monitor/), I tore
apart a Flume water monitor and traced its communication path from the sensor,
through the bridge, and up to Flume's cloud MQTT server. I identified the
encryption library (LibHydrogen), extracted a firmware ELF, and even managed to
coerce the bridge into sending plaintext by corrupting the public key in flash.
But that approach was destructive; the bridge couldn't complete its handshake
with Flume's server, so real data stopped flowing.

Thinking I had reached a dead end, only to find another path turned out to be a
pretty common occurrence for me. More and more thoughts on what I could have
done differently, and what further research I could have done kept coming to
me. And so I set out to continue to pursue my unhealthy obsession of figuring
out exactly how I can read this data on the network.

<!--more-->

## Why I Thought This Would Be Harder

The firmware contains a full LibHydrogen Noise N key exchange implementation.
In the disassembly, `hydro_kx_n_1` lives at `0x4023382c` (client side) and
`flume_kx_init_client` at `0x40234550` calls it with `PSK=NULL` and the
server's public key loaded from flash. These functions have real
cross-references to session key storage locations. Everything pointed to the
bridge negotiating ephemeral session keys with Flume's server, which would have
made passive decryption impossible without writing a custom key pair to flash
and implementing the full key exchange in the relay. I actually did do this and
hoped to see it working, only to face yet another disappointment.

From the previous investigation, when I invalidated the magic prefix on the key
storage area, Flume's server responded with error 174: "Phydro crypto key
exchange function failed." That error message, combined with the key exchange
code in the firmware, made it seem certain that session keys were in play.

But when I actually captured live traffic and tried decrypting with just the
static device key, everything decrypted cleanly. No session keys involved. I'm
sure I tried this last time, but I must not have had all secretbox parameters
correct.

The Noise N code exists in the firmware but isn't active for normal MQTT
traffic. It might be used for OTA updates, or a provisioning step that only
runs once, or it may be a remnant of an older protocol version. I don't know.
What matters is that in practice, the bridge encrypts and decrypts all messages
with the same static 32-byte key stored in flash. Or at least mine does.

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

Some might see these SecretBox context and message ID parameters and have a
chuckle, but I don't think Flume has done anything wrong in choosing them. The
libhydrogen docs say about context that [its purpose is to mitigate accidental
bugs by separating
domains](https://github.com/jedisct1/libhydrogen/wiki/Contexts). There's
probably only one domain in this scheme, so 12345678 is just as appropriate as
any other context. And regarding message IDs, the docs also say

> If this mechanism is not required by an application, using a constant msg_id
> such as 0 is also totally fine. Message identifiers are optional and do not
> have to be unique.

They were findable in the firmware, or guessable although clearly I didn't
guess them correctly last time. Regardless, with these parameters known, any
message can be decrypted.

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

With the key and encryption parameters in hand, I built
[flumewatch](https://github.com/stevecrozz/flumewatch), a transparent
man-in-the-middle relay that sits between the bridge and Flume's cloud server.
It forwards all traffic untouched while decrypting a copy of each message for
local consumption.

The bridge connects to `mqtt.prod.flumetech.com` on port 1883 (plain TCP, no
TLS). By redirecting this traffic at the network layer, either with DNS
overrides or destination NAT on the router, the bridge connects to the relay
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

When the bridge powers on, the handshake tells a clear story:

**Step 1: Identification (type 7).** The bridge's first message identifies
itself with a firmware branch and commit:

```json
{"bridge_id": null, "branch": "squidward", "sha_full": "2f1c870a72eca7d7eb38cb145718a202fe1c4a86"}
```

**Step 2: Boot logs (type 3).** Immediately after, the bridge sends
diagnostic log messages with its reset reason and firmware version:

```json
[
  {"timestamp": 0, "type": 1, "level": 4, "message": "RST REASON:  DIRTY  "},
  {"timestamp": 0, "type": 1, "level": 4, "message": "SDK reset #6: external"},
  {"timestamp": 0, "type": 1, "level": 4, "message": "SHA: 2f1c870a72eca7d7eb38cb145718a202fe1c4a86 | BRANCH: squidward"}
]
```

**Step 3: Server response.** Flume's server acknowledges the connection,
lists paired sensors, and returns a settings object:

```json
{
  "code": 602,
  "message": "Request OK",
  "timestamp": 1785096108,
  "sensors": ["62AC1323E5A55F6F"],
  "devices": [{"uuid": "62AC1323E5A55F6F", "hardware_id": "ASY-00007"}],
  "settings": {
    "1": 1, "2": "/provisioning", "3": "/frames",
    "4": "/responses", "5": "mqtt.flumewater.com:1883",
    "6": 30000, "7": 1200000, "8": 4093, "9": 65281,
    "10": 14, "11": 261135, "12": 12, "13": 60, "14": 0
  }
}
```

The settings include the MQTT endpoint (`"5": "mqtt.flumewater.com:1883"`,
confirming plain TCP with no TLS), what appear to be timing intervals (`"6":
30000`, `"7": 1200000` — possibly reporting cadence and heartbeat interval in
milliseconds), and various configuration flags whose purposes are unknown.

**Step 4: Post-handshake events (type 4).** Once the handshake completes,
the bridge fires a batch of event codes:

```json
[
  {"timestamp": 1785096110, "type": 1},
  {"timestamp": 1785096110, "type": 1024},
  {"timestamp": 1785096110, "type": 16384}
]
```

The event codes are powers of 2. Their exact meanings are unknown, but they
appear consistently after a successful handshake, suggesting they signal
startup state transitions.

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

## Wrapping Up

Since this time I have actually decrypted information on the network, I decided
to be a responsible human and actually let the folks at Flume know what I'd done.
They responded professionally and confirmed that each device has a random
secret key, so nobody's water usage info should be compromised by my publishing
this blog entry.

James Fazio (Flume CTO) wanted to point out that

> If the [bridge] device is configured to connect to a local MQTT server rather
> than Flume's service, it will no longer receive firmware updates or technical
> support from Flume.

I probably will actually go back to using the Flume cloud MQTT service soon
because I do want my device to have Flume's support. I don't think Flume can
tell the difference between when I am or am not running my proxy. But it is
possible because of all the blunt network shenanigans I pulled to redirect the
traffic and that could indeed prevent firmware updates. Now at least we know
that we can keep these devices running even without Flume should that need ever
arise.

In my opinion, the security employed here is actually adequate. I was only able
to gain access to this information because I had prolonged physical access to
the hardware, a willingness to probe my device with esptool and complete access
to the local network where it lives. That's a pretty high bar, especially if
anyone can learn the same info by opening my water meter pot on the sidewalk
and having a look.

I know that by publishing, this all may get "fixed" in a security update. But I
honestly hope it doesn't. I would like to offer an idea for Flume.

How about a 'developer mode' where I can specify my own, or at least an
additional MQTT server? It could make a best-effort delivery. It might even be
useful for your own developers. And indicating that the feature is only for
developers means it wouldn't have to be a first class product feature with all
the support burden that comes along for the ride. If that had existed, I
definitely would not have spent all this time working on what turned out to be
an interesting puzzle for me.

## What More Could Be Done

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
