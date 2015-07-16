---
layout: post
published: true
title: Inserting Errors with the Quickness
date: '2015-07-15 19:52:03 -0700'
tags:
- errbit
- mongo
- rails
---
[Last week]({% post_url 2015-07-04-why-errbit-is-slow %}), I continued my
exploration into Errbit slowness. I eliminated a few ideas and added a few more
conjectures to the list of optimization targets. While testing some ideas, I
began to suspect that my [test
rig](https://github.com/stevecrozz/errbit_loader) was not working as designed.
There was a flaw in the way I was using
[Typheous](https://github.com/typhoeus/typhoeus) that was causing the test
process to run slower than it should and even worse, report inaccurate
statistics.

So I reworked the test rig to manage its own threads and take its own request
time measurements. The test process now runs much faster and on v0.4.0 reports
response times that are a little less than half of what I had logged
previously.

Testing against my latest
[mongoid5](https://github.com/stevecrozz/errbit/tree/c319f32e9ee89be198f23562b6abd7d0306bd3de)
branch, where I've been accumulating performance optimization ideas reveals
that performance has actually improved significantly. It's unfortunate that
because my test rig had been inaccurate as I was making changes, I can't easily
show which changes correspond to how much of this improvement.

<script type="text/javascript" src="https://www.google.com/jsapi"></script>
<script>
var script = document.getElementsByTagName("script");
script = script[script.length - 1];
var chartEl = document.createElement('div');
script.parentNode.insertBefore(chartEl, script.nextSibling);

google.load('visualization', '1', {packages: ['corechart', 'line']});
google.setOnLoadCallback(function(){
  (function(){
    var data = new google.visualization.DataTable();
    data.addColumn('number', 'Errors');
    data.addColumn('number', 'v0.4.0');
    data.addColumn('number', 'HEAD');

    data.addRows(
      [
        [1, 0.435, 0.191], [2, 0.433, 0.192], [3, 0.441, 0.221], [4, 0.459, 0.204], [5, 0.441, 0.198], [6, 0.428, 0.197], [7, 0.375, 0.199], [8, 0.376, 0.201], [9, 0.375, 0.197], [10, 0.389, 0.195],
        [11, 0.381, 0.195], [12, 0.377, 0.2], [13, 0.376, 0.191], [14, 0.376, 0.206], [15, 0.375, 0.2], [16, 0.436, 0.184], [17, 0.476, 0.19], [18, 0.445, 0.182], [19, 0.437, 0.19], [20, 0.435, 0.178],
        [21, 0.433, 0.189], [22, 0.47, 0.186], [23, 0.457, 0.2], [24, 0.451, 0.199], [25, 0.437, 0.178], [26, 0.438, 0.18], [27, 0.436, 0.207], [28, 0.482, 0.212], [29, 0.439, 0.195], [30, 0.444, 0.182],
        [31, 0.444, 0.187], [32, 0.44, 0.186], [33, 0.437, 0.182], [34, 0.5, 0.186], [35, 0.447, 0.176], [36, 0.452, 0.192], [37, 0.438, 0.177], [38, 0.435, 0.19], [39, 0.469, 0.179], [40, 0.441, 0.187],
        [41, 0.447, 0.181], [42, 0.44, 0.181], [43, 0.43, 0.188], [44, 0.432, 0.212], [45, 0.492, 0.19], [46, 0.437, 0.204], [47, 0.446, 0.193], [48, 0.433, 0.196], [49, 0.44, 0.202], [50, 0.427, 0.193],
        [51, 0.457, 0.191], [52, 0.432, 0.192], [53, 0.437, 0.182], [54, 0.428, 0.191], [55, 0.437, 0.188], [56, 0.479, 0.186], [57, 0.435, 0.187], [58, 0.428, 0.186], [59, 0.44, 0.187], [60, 0.44, 0.181],
        [61, 0.433, 0.184], [62, 0.445, 0.184], [63, 0.432, 0.183], [64, 0.431, 0.183], [65, 0.512, 0.187], [66, 0.439, 0.178], [67, 0.436, 0.219], [68, 0.446, 0.196], [69, 0.439, 0.192], [70, 0.434, 0.194],
        [71, 0.432, 0.194], [72, 0.419, 0.196], [73, 0.427, 0.192], [74, 0.45, 0.201], [75, 0.422, 0.191], [76, 0.429, 0.199], [77, 0.421, 0.193], [78, 0.422, 0.195], [79, 0.429, 0.193], [80, 0.453, 0.197],
        [81, 0.434, 0.183], [82, 0.443, 0.197], [83, 0.429, 0.184], [84, 0.445, 0.206], [85, 0.462, 0.202], [86, 0.433, 0.202], [87, 0.441, 0.189], [88, 0.439, 0.185], [89, 0.434, 0.174], [90, 0.452, 0.176],
        [91, 0.469, 0.183], [92, 0.436, 0.178], [93, 0.432, 0.178], [94, 0.431, 0.173], [95, 0.438, 0.184], [96, 0.438, 0.179], [97, 0.473, 0.179], [98, 0.435, 0.186], [99, 0.438, 0.186], [100, 0.44, 0.196]
      ]
    );

    var options = {
      title: 'Request Time Overview (95th Percentile)',
      hAxis: {
        title: 'Number of errors inserted (in thousands)',
        ticks: [1,10,20,30,40,50,60,70,80,90,100]
      },
      vAxis: {
        viewWindow: { max: 0.6 },
        title: 'Seconds'
      },
    };

    var chart = new google.visualization.LineChart(chartEl);
    chart.draw(data, options);
  })();
});
</script>

My focus up until this point has been mainly in creating error reports, and
these numbers reflect a pretty significant improvement. It's nice to finally
see some real improvement after all this research.
