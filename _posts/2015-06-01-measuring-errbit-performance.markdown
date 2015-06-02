---
layout: post
published: true
title: Measuring Errbit Performance
date: '2015-06-01 19:13:50 -0700'
tags:
- errbit
- mongo
- rails
---
For some time, I've been aware that the performance of
[Errbit](https://github.com/errbit/errbit) is not great. But that problem has
so far taken a back seat to Errbit's other priorities. For v0.5.0, I want to at
least make a dent here and actually do something to improve this situation.

But before I get started, I felt like it was a good idea to put together some
kind of bench test for two reasons. First, I want a record of where this began
so I can see how much progress we make over time. Second, and more importantly,
I need a decision making framework. If I need to make a decision to sacrafice
some functionality for performance, I want to have a handle on how much
relative performance is at stake.

My goal is not to create a perfect or objective or complete measurement of
Errbit's behavior, but simply to get a sense of how Errbit's performance
characteristics change as errors are added to its database and as the code
changes over the course of this performance improvement project.

## Testing Methodology

To start, I created
[errbit_loader](https://github.com/stevecrozz/errbit_loader) with a pair of
load tests for the two most common errbit uses, creating and finding errors.
You start the test by specifying the number of errors to create and search for
in each block (count), and the number of parallel requests to keep open at any
one time (concurrency). In this round of testing, I used count=1000 and
concurrency=8. In each test, errbit_loader runs the create batch, followed by
the search batch and then repeats this pair of tests until stopped.

90% of the errors created by errbit_loader are repeating, so they should be
grouped with other like errors. The other 10% have unique messages which should
cause them to be not grouped with other errors.

I know from experience that performance degrades tremendously with many
millions of errors, but it took more than six hours just to create 100,000
errors in these load tests in my environment. For that reason, I have decided
to stop at 100,000 for now and increase the total count after we make some
progress.

## Software and Hardware Information

For this round of testing, I am using [Errbit
v0.4.0](https://github.com/errbit/errbit/tree/v0.4.0), Ruby 2.1.2, and mongo
2.6.3. Errbit is using its default deployment strategy which is single-threaded
unicorn with three worker processes and preload_app set to true. The test
process, mongo, and Errbit itself are all running on the same physical machine
which is a Lenovo ThinkPad T430s.

In just over six hours (6:02.59), I inserted 100,000 errors, in blocks of 1,000
and completed 100,000 searches. There is a bit of noise in these data between
80-90k because I forgot the tests were running at one point and started using
my laptop for other things. The results should still be usable, though, since
the underlying trends are clearly visible.

This first chart is a total request time overview. Out of each block of 1,000
tests, I'm showing the 95th percentile, with five percent of requests being
slower than each point on the chart. Time to insert errors appears to be fairly
constant as the database grows, while searching seems to grow linearly.

<div id="2015-06-01-chart-overview"></div>

Here's a closer look at the results for creates. This chart shows the 90th,
95th and 99th percentile.

<div id="2015-06-01-chart-creates"></div>

And here's the same view of search requests.

<div id="2015-06-01-chart-searches"></div>

My hunch is we can do a lot better than this. Instinctively, it doesn't seem
like it should take anywhere near a full second to insert an error. I'm not
completely unhappy with the results for search requests, but I think that's
only because there are still relatively few errors in the database. Once we
speed up the inserts, we should be able to more easily test how performance
degrades as we start getting into millions of errors.

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
    data.addColumn('number', 'Creating');
    data.addColumn('number', 'Searching');

    data.addRows(
      [
        [1, 1.0736, 0.4455], [2, 1.0734, 0.4679], [3, 1.0851, 0.4971], [4, 1.077, 0.5485], [5, 1.081, 0.566], [6, 1.0788, 0.765], [7, 1.0916, 0.5753], [8, 1.0779, 0.6026], [9, 1.0807, 0.6057], [10, 1.0812, 0.6036],
        [11, 1.0812, 0.6176], [12, 1.08, 0.6219], [13, 1.08, 0.6359], [14, 1.0781, 0.6398], [15, 1.0775, 0.6407], [16, 1.0812, 0.6288], [17, 1.0788, 0.6368], [18, 1.0771, 0.6467], [19, 1.0764, 0.6501], [20, 1.0794, 0.6497],
        [21, 1.0798, 0.6459], [22, 1.0739, 0.6519], [23, 1.0798, 0.6498], [24, 1.079, 0.6695], [25, 1.0778, 0.6709], [26, 1.0794, 0.6674], [27, 1.0796, 0.6828], [28, 1.0798, 0.6809], [29, 1.0774, 0.6839], [30, 1.0809, 0.6841],
        [31, 1.078, 0.6955], [32, 1.0788, 0.6965], [33, 1.077, 0.6957], [34, 1.0791, 0.7047], [35, 1.0787, 0.6898], [36, 1.0761, 0.707], [37, 1.0781, 0.707], [38, 1.0817, 0.7146], [39, 1.0792, 0.7229], [40, 1.0795, 0.7263],
        [41, 1.0805, 0.7247], [42, 1.0761, 0.7281], [43, 1.0775, 0.7468], [44, 1.0819, 0.741], [45, 1.0777, 0.7468], [46, 1.0807, 0.7487], [47, 1.0799, 0.7595], [48, 1.0818, 0.7539], [49, 1.077, 0.7546], [50, 1.0796, 0.7676],
        [51, 1.0785, 0.7712], [52, 1.0799, 0.7961], [53, 1.078, 0.7965], [54, 1.0804, 0.7878], [55, 1.0797, 0.789], [56, 1.077, 0.7975], [57, 1.0801, 0.801], [58, 1.0759, 0.83], [59, 1.3551, 0.7899], [60, 1.0756, 0.7804],
        [61, 1.0776, 0.7843], [62, 1.0763, 0.778], [63, 1.073, 0.8751], [64, 1.079, 1.1896], [65, 1.0936, 1.1944], [66, 1.0701, 0.817], [67, 1.0761, 0.7843], [68, 1.0711, 0.802], [69, 1.0693, 0.7715], [70, 1.073, 0.8045],
        [71, 1.0673, 0.7976], [72, 1.0663, 0.8186], [73, 1.0706, 0.8157], [74, 1.0765, 0.8117], [75, 1.072, 0.8485], [76, 1.0701, 0.8204], [77, 1.0788, 0.8284], [78, 1.0775, 0.8679], [79, 1.1628, 0.8783], [80, 1.0779, 2.1584],
        [81, 1.1853, 2.1924], [82, 1.1937, 2.2102], [83, 1.1718, 1.9334], [84, 1.1797, 1.951], [85, 1.1746, 1.9379], [86, 1.1636, 1.9525], [87, 1.1867, 1.9633], [88, 1.0745, 1.0476], [89, 1.0774, 1.3616], [90, 1.0741, 1.0267],
        [91, 1.0799, 0.872], [92, 1.0734, 0.8651], [93, 1.0745, 0.8669], [94, 1.0722, 0.9028], [95, 1.074, 0.8789], [96, 1.0716, 0.8705], [97, 1.0702, 0.8804], [98, 1.0663, 0.9034], [99, 1.069, 0.8955], [100, 1.0698, 0.9025]
      ]
    );

    var options = {
      title: 'Request Time Overview (95th Percentile)',
      hAxis: {
        title: 'Number of errors (in thousands)',
        ticks: [1,10,20,30,40,50,60,70,80,90,100]
      },
      vAxis: {
        viewWindow: { max: 1.5 },
        title: 'Seconds'
      },
    };

    var chart = new google.visualization.LineChart(document.getElementById('2015-06-01-chart-overview'));
    chart.draw(data, options);
  })();

  (function(){
    var data = new google.visualization.DataTable();
    data.addColumn('number', 'Errors');
    data.addColumn('number', '90th');
    data.addColumn('number', '95th');
    data.addColumn('number', '99th');

    data.addRows(
      [
        [1, 1.064337, 1.073553, 1.099031], [2, 1.066721, 1.073393, 1.102183], [3, 1.072884, 1.085073, 1.127303], [4, 1.070369, 1.0770469999999999, 1.101146], [5, 1.072786, 1.081007, 1.113317], [6, 1.068816, 1.078775, 1.109752], [7, 1.07733, 1.091564, 1.175292], [8, 1.068696, 1.07791, 1.106564], [9, 1.070265, 1.080657, 1.104476], [10, 1.072066, 1.0812, 1.105055],
        [11, 1.07264, 1.081178, 1.112684], [12, 1.069426, 1.079969, 1.102615], [13, 1.068759, 1.080004, 1.111448], [14, 1.067711, 1.078124, 1.1173980000000001], [15, 1.070998, 1.077526, 1.105743], [16, 1.068683, 1.081196, 1.105947], [17, 1.069183, 1.078774, 1.10628], [18, 1.069016, 1.0770710000000001, 1.10309], [19, 1.067355, 1.076392, 1.102709], [20, 1.069491, 1.07941, 1.107175],
        [21, 1.069266, 1.079845, 1.099659], [22, 1.0664069999999999, 1.073912, 1.108758], [23, 1.070432, 1.079809, 1.113026], [24, 1.067966, 1.078954, 1.108834], [25, 1.068665, 1.077778, 1.107037], [26, 1.068409, 1.079392, 1.108912], [27, 1.071354, 1.079604, 1.108712], [28, 1.07049, 1.079847, 1.111712], [29, 1.06481, 1.077409, 1.104746], [30, 1.0722239999999998, 1.08093, 1.1226],
        [31, 1.067626, 1.077994, 1.121504], [32, 1.071609, 1.078801, 1.118838], [33, 1.066414, 1.076985, 1.1007500000000001], [34, 1.067445, 1.079095, 1.113654], [35, 1.065778, 1.078689, 1.110343], [36, 1.069623, 1.076085, 1.105748], [37, 1.068479, 1.078139, 1.110489], [38, 1.071914, 1.0817, 1.119582], [39, 1.068906, 1.079202, 1.114045], [40, 1.069107, 1.079502, 1.129164],
        [41, 1.072116, 1.080532, 1.107427], [42, 1.066211, 1.076095, 1.123316], [43, 1.066212, 1.077516, 1.120145], [44, 1.065532, 1.08189, 1.124939], [45, 1.068598, 1.07765, 1.111662], [46, 1.066012, 1.080655, 1.123265], [47, 1.070076, 1.079875, 1.116418], [48, 1.0719, 1.081801, 1.116352], [49, 1.065827, 1.077012, 1.116061], [50, 1.067767, 1.079595, 1.118892],
        [51, 1.067415, 1.078458, 1.113523], [52, 1.070969, 1.079888, 1.107452], [53, 1.067245, 1.07804, 1.106544], [54, 1.071055, 1.080432, 1.103272], [55, 1.066537, 1.079677, 1.120543], [56, 1.067348, 1.076981, 1.120578], [57, 1.068954, 1.0801, 1.113904], [58, 1.064865, 1.075894, 1.106594], [59, 1.281932, 1.3550879999999998, 1.5538129999999999], [60, 1.06493, 1.075629, 1.108315],
        [61, 1.066168, 1.077618, 1.104772], [62, 1.064651, 1.076307, 1.108299], [63, 1.059926, 1.073042, 1.092239], [64, 1.061695, 1.079031, 1.121393], [65, 1.084535, 1.093552, 1.123206], [66, 1.0604770000000001, 1.070076, 1.117258], [67, 1.062776, 1.076051, 1.105438], [68, 1.060859, 1.071147, 1.109348], [69, 1.060358, 1.0692620000000002, 1.107181], [70, 1.060437, 1.072961, 1.1045449999999999],
        [71, 1.059677, 1.06732, 1.101165], [72, 1.058762, 1.066348, 1.095901], [73, 1.061403, 1.0705770000000001, 1.099818], [74, 1.066047, 1.076463, 1.118112], [75, 1.062832, 1.072003, 1.108638], [76, 1.0601180000000001, 1.070117, 1.107117], [77, 1.062293, 1.078787, 1.118924], [78, 1.063589, 1.077473, 1.118701], [79, 1.143417, 1.162765, 1.236464], [80, 1.063988, 1.077939, 1.12218],
        [81, 1.155276, 1.185303, 1.2846929999999999], [82, 1.1687, 1.193657, 1.275084], [83, 1.15076, 1.171772, 1.234948], [84, 1.15755, 1.1797330000000001, 1.246597], [85, 1.153086, 1.1746189999999999, 1.260304], [86, 1.133839, 1.163613, 1.228143], [87, 1.160337, 1.1866780000000001, 1.277665], [88, 1.063709, 1.074524, 1.104964], [89, 1.062669, 1.077358, 1.10698], [90, 1.061916, 1.074073, 1.105509],
        [91, 1.066594, 1.07992, 1.116408], [92, 1.057671, 1.073444, 1.101766], [93, 1.064316, 1.074476, 1.107729], [94, 1.062925, 1.072158, 1.103563], [95, 1.063396, 1.073955, 1.102137], [96, 1.060939, 1.071579, 1.092512], [97, 1.061165, 1.070247, 1.102579], [98, 1.057606, 1.066316, 1.110047], [99, 1.060005, 1.068958, 1.102382], [100, 1.05823, 1.069822, 1.109818]
      ]
    );

    var options = {
      title: 'Request Times for Searches',
      hAxis: {
        title: 'Number of errors (in thousands)',
        ticks: [1,10,20,30,40,50,60,70,80,90,100]
      },
      vAxis: {
        viewWindow: { max: 1.5 },
        title: 'Seconds'
      },
    };

    var chart = new google.visualization.LineChart(document.getElementById('2015-06-01-chart-creates'));
    chart.draw(data, options);
  })();

  (function(){
    var data = new google.visualization.DataTable();
    data.addColumn('number', 'Errors');
    data.addColumn('number', '90th');
    data.addColumn('number', '95th');
    data.addColumn('number', '99th');

    data.addRows(
      [
        [1, 0.412768, 0.44549000000000005, 0.513298], [2, 0.437131, 0.467909, 0.543048], [3, 0.459288, 0.497096, 0.546526], [4, 0.517611, 0.5485439999999999, 0.605912], [5, 0.533243, 0.566047, 0.6264959999999999], [6, 0.685143, 0.765035, 0.930747], [7, 0.544667, 0.575349, 0.631821], [8, 0.564059, 0.602616, 0.678388], [9, 0.577284, 0.605731, 0.660046], [10, 0.574608, 0.603559, 0.668354],
        [11, 0.584921, 0.617638, 0.6633290000000001], [12, 0.593988, 0.621918, 0.686053], [13, 0.597166, 0.635902, 0.680031], [14, 0.606287, 0.639807, 0.689468], [15, 0.603613, 0.640709, 0.699588], [16, 0.596421, 0.628795, 0.687704], [17, 0.605254, 0.636755, 0.684314], [18, 0.6168819999999999, 0.646746, 0.708619], [19, 0.6213850000000001, 0.650131, 0.7108209999999999], [20, 0.621583, 0.64971, 0.7016370000000001],
        [21, 0.616632, 0.645899, 0.7165], [22, 0.6197550000000001, 0.651946, 0.695108], [23, 0.6180030000000001, 0.649799, 0.712623], [24, 0.632169, 0.669501, 0.716222], [25, 0.640352, 0.670883, 0.715948], [26, 0.641376, 0.667422, 0.703964], [27, 0.656655, 0.6828190000000001, 0.723516], [28, 0.658481, 0.680885, 0.72094], [29, 0.654593, 0.683913, 0.733331], [30, 0.655044, 0.684068, 0.735652],
        [31, 0.67001, 0.695515, 0.7568699999999999], [32, 0.657988, 0.696525, 0.751458], [33, 0.66578, 0.6957340000000001, 0.755267], [34, 0.674902, 0.704683, 0.7575000000000001], [35, 0.666581, 0.68979, 0.744386], [36, 0.678318, 0.706961, 0.755171], [37, 0.683204, 0.706964, 0.761946], [38, 0.690694, 0.714563, 0.76265], [39, 0.699749, 0.722877, 0.776239], [40, 0.701208, 0.726328, 0.781984],
        [41, 0.699404, 0.724738, 0.779815], [42, 0.703634, 0.728122, 0.769099], [43, 0.710617, 0.746766, 0.790964], [44, 0.710776, 0.741023, 0.782313], [45, 0.720289, 0.746759, 0.795971], [46, 0.720066, 0.748735, 0.790366], [47, 0.728126, 0.759486, 0.8196680000000001], [48, 0.7336469999999999, 0.753949, 0.809684], [49, 0.725654, 0.754601, 0.805769], [50, 0.74063, 0.7676270000000001, 0.80792],
        [51, 0.743158, 0.7712330000000001, 0.8286100000000001], [52, 0.765455, 0.796149, 0.842662], [53, 0.763823, 0.796528, 0.845853], [54, 0.759532, 0.787788, 0.841227], [55, 0.759038, 0.7890429999999999, 0.849655], [56, 0.7643139999999999, 0.7974600000000001, 0.8576239999999999], [57, 0.775153, 0.8009850000000001, 0.859754], [58, 0.796633, 0.830033, 0.891387], [59, 0.759577, 0.789934, 0.875193], [60, 0.755733, 0.780375, 0.869459],
        [61, 0.757804, 0.784281, 0.827939], [62, 0.75124, 0.777998, 0.825111], [63, 0.819707, 0.875109, 0.960197], [64, 1.078106, 1.189601, 1.494937], [65, 1.103496, 1.194391, 1.3892039999999999], [66, 0.777187, 0.81696, 0.870731], [67, 0.751446, 0.784282, 0.855125], [68, 0.750857, 0.8019689999999999, 0.915986], [69, 0.7398629999999999, 0.771493, 0.816789], [70, 0.77321, 0.804493, 0.8503499999999999],
        [71, 0.76733, 0.797585, 0.8635740000000001], [72, 0.7789429999999999, 0.818644, 0.889088], [73, 0.7864990000000001, 0.815727, 0.875467], [74, 0.784329, 0.811712, 0.8942330000000001], [75, 0.797168, 0.8484510000000001, 0.97157], [76, 0.793539, 0.820352, 0.874558], [77, 0.791664, 0.828354, 0.890047], [78, 0.826318, 0.867887, 0.923365], [79, 0.8500030000000001, 0.878306, 0.985571], [80, 2.031434, 2.15843, 2.59296],
        [81, 2.101118, 2.19236, 2.3627000000000002], [82, 2.083658, 2.210187, 2.497286], [83, 1.837101, 1.93342, 2.094234], [84, 1.841561, 1.950971, 2.144427], [85, 1.834431, 1.937851, 2.073679], [86, 1.834865, 1.952501, 2.104979], [87, 1.862587, 1.963345, 2.12103], [88, 0.947871, 1.047633, 1.166115], [89, 1.152815, 1.361623, 1.851389], [90, 0.941131, 1.026715, 1.22678],
        [91, 0.847028, 0.871992, 0.937717], [92, 0.832565, 0.8651409999999999, 0.925058], [93, 0.832194, 0.866921, 0.920571], [94, 0.85672, 0.902792, 0.997833], [95, 0.845581, 0.878945, 0.923656], [96, 0.8421069999999999, 0.87047, 0.937496], [97, 0.853537, 0.880363, 0.936775], [98, 0.873509, 0.903386, 0.983487], [99, 0.865915, 0.895507, 0.963151], [100, 0.878089, 0.902477, 0.96358]
      ]
    );

    var options = {
      title: 'Request Times for Searches',
      hAxis: {
        title: 'Number of errors (in thousands)',
        ticks: [1,10,20,30,40,50,60,70,80,90,100]
      },
      vAxis: {
        viewWindow: { max: 1.5 },
        title: 'Seconds'
      },
    };

    var chart = new google.visualization.LineChart(document.getElementById('2015-06-01-chart-searches'));
    chart.draw(data, options);
  })();
});
</script>
