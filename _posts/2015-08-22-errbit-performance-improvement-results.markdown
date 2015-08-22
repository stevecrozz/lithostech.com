---
layout: post
published: true
title: Errbit Performance Improvement Results
date: '2015-08-22 14:07:46 -0700'
tags:
- errbit
- mongo
- rails
---
My battle with Errbit performance is over for the time being. This concludes an
effort I began in June to improve throughput on error inserts and error
searching as the database grows over time. If you're interested in reading
about the effort leading up to this point, here are the related posts:

- [Measuring Errbit Performance]({% post_url 2015-06-01-measuring-errbit-performance %})
- [Why Errbit Is Slow]({% post_url 2015-07-04-why-errbit-is-slow %})
- [Inserting Errors with the Quickness]({% post_url 2015-07-15-inserting-errors-with-the-quickness %})

The short version of the story is that I tried all kinds of ideas, but failed
to notice the actual improvements due to an issue with the [special purpose test
rig](https://github.com/stevecrozz/errbit_loader) I created specifically for
measuring these improvements. Once I found and fixed the test rig issue, it was
clear that my efforts had paid off. Unfortunately, it was not clear which ones
had the biggest impact because I had hoped this final post would be an
evidence-based exploration into where the performance issues lived.

Instead, I only have evidence that the sum total of my effort lead to a real
and measurable performance impact and I can speculate as to where the largest
gains were had. But first, let's look at the overall impact in the two areas
where we have data, starting with error insertion:

<script>
(function(){
  var script = document.getElementsByTagName("script");
  script = script[script.length - 1];
  var chartEl = document.createElement('div');
  script.parentNode.insertBefore(chartEl, script.nextSibling);

  window.chartCallbacks = window.chartCallbacks || [];
  chartCallbacks.push(function(){
    var data = new google.visualization.DataTable();
    data.addColumn('number', 'Errors');
    data.addColumn('number', 'v0.4.0');
    data.addColumn('number', 'HEAD');

    data.addRows(
      [
        [1,0.377,0.195],[2,0.39,0.195],[3,0.417,0.194],[4,0.44,0.197],[5,0.443,0.194],[6,0.451,0.189],[7,0.421,0.196],[8,0.419,0.198],[9,0.421,0.197],[10,0.421,0.193],
        [11,0.42,0.205],[12,0.427,0.199],[13,0.417,0.2],[14,0.424,0.182],[15,0.427,0.18],[16,0.431,0.176],[17,0.426,0.178],[18,0.432,0.177],[19,0.428,0.176],[20,0.555,0.182],
        [21,0.497,0.178],[22,0.7,0.181],[23,0.83,0.178],[24,0.413,0.179],[25,0.423,0.191],[26,0.437,0.201],[27,0.417,0.247],[28,0.419,0.183],[29,0.421,0.178],[30,0.425,0.186],
        [31,0.428,0.208],[32,0.421,0.193],[33,0.424,0.206],[34,0.424,0.201],[35,0.415,0.213],[36,0.423,0.202],[37,0.42,0.199],[38,0.419,0.198],[39,0.41,0.197],[40,0.413,0.194],
        [41,0.418,0.257],[42,0.426,0.199],[43,0.423,0.2],[44,0.419,0.197],[45,0.421,0.201],[46,0.424,0.201],[47,0.416,0.2],[48,0.43,0.2],[49,0.411,0.197],[50,0.421,0.205],
        [51,0.418,0.199],[52,0.419,0.197],[53,0.415,0.196],[54,0.433,0.196],[55,0.422,0.204],[56,0.427,0.201],[57,0.426,0.2],[58,0.419,0.192],[59,0.435,0.199],[60,0.423,0.197],
        [61,0.426,0.201],[62,0.422,0.201],[63,0.42,0.199],[64,0.42,0.21],[65,0.421,0.203],[66,0.425,0.2],[67,0.431,0.2],[68,0.428,0.201],[69,0.43,0.203],[70,0.424,0.199],
        [71,0.42,0.203],[72,0.426,0.2],[73,0.427,0.2],[74,0.421,0.199],[75,0.424,0.197],[76,0.431,0.201],[77,0.424,0.199],[78,0.429,0.2],[79,0.427,0.202],[80,0.43,0.203],
        [81,0.424,0.195],[82,0.424,0.201],[83,0.429,0.2],[84,0.435,0.207],[85,0.428,0.197],[86,0.427,0.2],[87,0.42,0.192],[88,0.429,0.201],[89,0.43,0.197],[90,0.43,0.201],
        [91,0.434,0.203],[92,0.43,0.202],[93,0.432,0.201],[94,0.427,0.2],[95,0.428,0.197],[96,0.423,0.196],[97,0.432,0.195],[98,0.421,0.2],[99,0.436,0.201],[100,0.426,0.197]
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
  });
}());
</script>

My best guess as to why we're seeing this improvement is twofold. First, the
number of mongo queries required to insert an error are down to a minimum of
five rather than a minimum of nine. Secondly, inserting an error no longer
requires instantiating a Mongoid document for every line in the backtrace. In
fact, the model representing a backtrace line no longer exists at all. There
could be other explanations, but I'm satisfied with the results as they are.
Although I'd like to know where the improvements came from, I'm not inclined to
spend the time to figure it out at this point.

Next, we'll look at error searching:

<script>
(function(){
  var script = document.getElementsByTagName("script");
  script = script[script.length - 1];
  var chartEl = document.createElement('div');
  script.parentNode.insertBefore(chartEl, script.nextSibling);

  window.chartCallbacks = window.chartCallbacks || [];
  chartCallbacks.push(function(){
    var data = new google.visualization.DataTable();
    data.addColumn('number', 'Errors');
    data.addColumn('number', 'v0.4.0');
    data.addColumn('number', 'HEAD');

    data.addRows(
      [
        [1,0.685,0.328],[2,0.838,0.325],[3,0.841,0.326],[4,1.0,0.327],[5,1.009,0.32],[6,1.015,0.315],[7,1.026,0.326],[8,1.007,0.32],[9,1.016,0.318],[10,1.01,0.334],
        [11,1.054,0.339],[12,1.083,0.324],[13,1.041,0.327],[14,1.061,0.297],[15,1.082,0.3],[16,1.105,0.298],[17,1.101,0.308],[18,1.127,0.296],[19,1.136,0.331],[20,1.347,0.304],
        [21,1.533,0.298],[22,1.757,0.3],[23,1.178,0.3],[24,1.182,0.305],[25,1.196,0.341],[26,1.234,0.34],[27,1.244,0.316],[28,1.204,0.313],[29,1.226,0.331],[30,1.292,0.319],
        [31,1.234,0.335],[32,1.233,0.34],[33,1.256,0.335],[34,1.245,0.331],[35,1.271,0.342],[36,1.297,0.338],[37,1.274,0.338],[38,1.272,0.33],[39,1.289,0.341],[40,1.343,0.333],
        [41,1.322,0.337],[42,1.315,0.338],[43,1.31,0.339],[44,1.32,0.34],[45,1.321,0.337],[46,1.341,0.333],[47,1.369,0.34],[48,1.345,0.337],[49,1.363,0.344],[50,1.391,0.339],
        [51,1.36,0.338],[52,1.392,0.336],[53,1.396,0.336],[54,1.391,0.341],[55,1.388,0.341],[56,1.395,0.349],[57,1.406,0.345],[58,1.435,0.36],[59,1.442,0.343],[60,1.433,0.342],
        [61,1.433,0.35],[62,1.457,0.346],[63,1.432,0.346],[64,1.468,0.397],[65,1.478,0.354],[66,1.482,0.352],[67,1.484,0.348],[68,1.509,0.349],[69,1.522,0.346],[70,1.527,0.351],
        [71,1.508,0.355],[72,1.533,0.356],[73,1.516,0.335],[74,1.531,0.35],[75,1.55,0.386],[76,1.544,0.344],[77,1.54,0.349],[78,1.568,0.349],[79,1.57,0.352],[80,1.574,0.351],
        [81,1.579,0.317],[82,1.575,0.337],[83,1.575,0.34],[84,1.581,0.348],[85,1.633,0.345],[86,1.594,0.343],[87,1.598,0.344],[88,1.615,0.368],[89,1.632,0.346],[90,1.638,0.344],
        [91,1.616,0.376],[92,1.656,0.35],[93,1.654,0.347],[94,1.646,0.347],[95,1.67,0.341],[96,1.667,0.344],[97,1.709,0.342],[98,1.679,0.348],[99,1.683,0.349],[100,1.696,0.342]
      ]
    );

    var options = {
      title: 'Request Time Overview (95th Percentile)',
      hAxis: {
        title: 'Number of errors inserted (in thousands)',
        ticks: [1,10,20,30,40,50,60,70,80,90,100]
      },
      vAxis: {
        title: 'Seconds'
      },
    };

    var chart = new google.visualization.LineChart(chartEl);
    chart.draw(data, options);
  });
}());
</script>

<script type="text/javascript" src="https://www.google.com/jsapi"></script>
<script>
  google.load('visualization', '1', {packages: ['corechart', 'line']});
  google.setOnLoadCallback(function(){
    chartCallbacks.forEach(Function.prototype.call, Function.prototype.call);
  });
</script>

This is exactly the kind of result I was looking for. What began as seemingly
linear performance degradation now looks a lot more like constant time. It
isn't actually that good, but the performance degradation between zero and 100k
records is barely perceptible.

I'm convinced the meat of this improvement came from [switching to mongo's
built-in full-text search
mechanism](https://github.com/errbit/errbit/commit/43c0f238754c1e2848a7fdee832e7f0006262937#diff-037539c7ba3b471b09f5cd4fe163a69f).
It makes sense that using mongo's full-text search implementation would be much
more performant than doing a multi-index string search.

Hopefully our users will notice and appreciate these performance gains. Keep in
mind, the results shown above ran with a single thread and a single process.
Depending on your hardware, you should get better throughput in a real
deployment by running multiple processes and hopefully multiple threads in the
future.
