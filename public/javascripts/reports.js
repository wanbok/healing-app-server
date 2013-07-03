Array.prototype.remove = function(from, to) {
  var rest = this.slice((to || from) + 1 || this.length);
  this.length = from < 0 ? this.length + from : from;
  return this.push.apply(this, rest);
};

function correlate(numbers) {
  var mergedData = []
  var margin = {top: 20, right: 20, bottom: 30, left: 40},
      width = 800 - margin.left - margin.right,
      height = 800 - margin.top - margin.bottom;

  var x = d3.scale.linear()
      .range([0, width]);

  var y = d3.scale.linear()
      .range([height, 0]);

  var color = d3.scale.category10();

  var xAxis = d3.svg.axis()
      .scale(x)
      .orient("bottom");

  var yAxis = d3.svg.axis()
      .scale(y)
      .orient("left");

  var svg = d3.select("div.span12").append("svg")
      .attr("width", width + margin.left + margin.right)
      .attr("height", height + margin.top + margin.bottom)
    .append("g")
      .classed('chart', true)
      .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

  function drawBackground(data) {
    if (data != null) {
      x.domain(d3.extent(data, function(d) { return Math.round(d.measuredData.nomalizedUsageDurationPerDay); })).nice();
      y.domain(d3.extent(data, function(d) { return d.aggregation.total; })).nice();
    } else {
      x.domain(d3.extent([0, 8*60*60*1000], function(d) { return d; })).nice();
      y.domain(d3.extent([0, 60], function(d) { return d; })).nice();
    };

    svg.append("g")
        .attr("class", "x axis")
        .attr("transform", "translate(0," + height + ")")
        .call(xAxis)
      .append("text")
        .attr("class", "label")
        .attr("x", width)
        .attr("y", -6)
        .style("text-anchor", "end")
        .text("기기측정시간 (ms)");

    svg.append("g")
        .attr("class", "y axis")
        .call(yAxis)
      .append("text")
        .attr("class", "label")
        .attr("transform", "rotate(-90)")
        .attr("y", 6)
        .attr("dy", ".71em")
        .style("text-anchor", "end")
        .text("설문점수");

    d3.select('svg g.chart')
      .append('text')
      .attr({'id': 'userLabel', 'x': 0, 'y': 170})
      .style({'font-size': '40px', 'font-weight': 'bold', 'fill': '#ddd'});

    d3.select('svg g.chart')
      .append('line')
      .attr('id', 'bestfit')
  }

  function getCorrelation(xArray, yArray) {
    function sum(m, v) {return m + v;}
    function sumSquares(m, v) {return m + v * v;}
    function filterNaN(m, v, i) {isNaN(v) ? null : m.push(i); return m;}

    // clean the data (because we know that some values are missing)
    var xNaN = _.reduce(xArray, filterNaN , []);
    var yNaN = _.reduce(yArray, filterNaN , []);
    var include = _.intersection(xNaN, yNaN);
    var fX = _.map(include, function(d) {return xArray[d];});
    var fY = _.map(include, function(d) {return yArray[d];});

    var sumX = _.reduce(fX, sum, 0);
    var sumY = _.reduce(fY, sum, 0);
    var sumX2 = _.reduce(fX, sumSquares, 0);
    var sumY2 = _.reduce(fY, sumSquares, 0);
    var sumXY = _.reduce(fX, function(m, v, i) {return m + v * fY[i];}, 0);

    var n = fX.length;
    var ntor = ( ( sumXY ) - ( sumX * sumY / n) );
    var dtorX = sumX2 - ( sumX * sumX / n);
    var dtorY = sumY2 - ( sumY * sumY / n);
   
    var r = ntor / (Math.sqrt( dtorX * dtorY )); // Pearson ( http://www.stat.wmich.edu/s216/book/node122.html )
    var m = ntor / dtorX; // y = mx + b
    var b = ( sumY - m * sumX ) / n;

    // console.log(r, m, b);
    return {r: r, m: m, b: b};
  }

  function applyData(data) {
    svg.selectAll(".dot")
        .data(data)
      .enter().append("circle")
        .attr("id", function(d) { return d.survey.user; })
        .attr("class", "dot")
        .attr("r", 5)
        .attr("cx", function(d) { return x(Math.round(d.measuredData.nomalizedUsageDurationPerDay)); })
        .attr("cy", function(d) { return y(d.aggregation.total); })
        .style("fill", function(d) { return color(d.survey.sex); })
        .style('cursor', 'pointer')
        .on('mouseover', function(d) {
          d3.select('svg g #userLabel')
            .text(d.survey.user + ", 점수:" + d.aggregation.total + ", 측정:" + Math.round(d.measuredData.nomalizedUsageDurationPerDay / (60*60*1000)))
            .transition()
            .style('opacity', 1);
        })
        .on('mouseout', function(d) {
          d3.select('svg g #userLabel')
            .transition()
            .duration(1500)
            .style('opacity', 0);
        });

    var legend = svg.selectAll(".legend")
        .data(color.domain())
      .enter().append("g")
        .attr("class", "legend")
        .attr("transform", function(d, i) { return "translate(0," + i * 20 + ")"; });

    legend.append("rect")
        .attr("x", width - 18)
        .attr("width", 18)
        .attr("height", 18)
        .style("fill", color);

    legend.append("text")
        .attr("x", width - 24)
        .attr("y", 9)
        .attr("dy", ".35em")
        .style("text-anchor", "end")
        .text(function(d) { return d; });

    var xArray = _.map(data, function(d) {return Math.round(d.measuredData.nomalizedUsageDurationPerDay);});
    var yArray = _.map(data, function(d) {return d.aggregation.total;});
    var c = getCorrelation(xArray, yArray);
    var x1 = x.domain()[0], y1 = c.m * x1 + c.b;
    var x2 = x.domain()[1], y2 = c.m * x2 + c.b;

    d3.select('svg g.chart #bestfit')
      .style('opacity', 0)
      .attr({'x1': x(x1), 'y1': y(y1), 'x2': x(x2), 'y2': y(y2)})
      .transition()
      .duration(1500)
      .style('opacity', 1);
  }

  function pipelineCall(index) {
    d3.json("/correlate.json?userId=" + encodeURIComponent(numbers[index]), function(error, data) {
      console.log(numbers[index] + ": " + JSON.stringify(data));
      var userId = data[0].value.userId.replace(/\+82/, "0");
      var result = $.grep(mergedData, function(d) { return d.survey.user == userId; });
      if (result.length > 0) {
        result[0].measuredData = data[0].value;
      }
      if (numbers.length > index + 1) {
        pipelineCall(index + 1);
      } else {
        $.each(mergedData, function(i){
          if(typeof(mergedData[i]) == 'undefined' || typeof(mergedData[i].measuredData) == 'undefined') {
            mergedData.remove(i);
          }
        });
        applyData(mergedData);
      };
    });
  }

  function surveys() {
    d3.json("http://wanbok.com/surveys.json", function(error, data) {
      console.log("Survey count: " + data.length);
      data.forEach(function(d){
        d.survey.user = d.survey.user.replace(/-/gi, "");
      });
      mergedData = data
      pipelineCall(0);
    });
  }

  drawBackground();
  surveys();
}

function reports(reports) {
  // layer is appPkg
  // sample is user
  var n = reports.length,
      m = 1,
      stack = d3.layout.stack(),
      layers = stack(reports.map(function(d) { return calculateLayer(d); }));
  var xMax = d3.max(layers, function(layer) { return d3.max(layer, function(d) { return d.x; }); });
  var margin = {top: 40, right: 10, bottom: 20, left: 10},
      inset = {right: 150},
      barHeight = 25,
      width = 960 - margin.left - margin.right,
      height = (barHeight * n);

  var x = d3.scale.linear()
      .domain([0, xMax])
      .range([0, width - inset.right]);

  var y = d3.scale.ordinal()
      .domain([reports[0].value.userId])
      .rangeRoundBands([0, height], .08);

  var color = d3.scale.category20();

  var svg = d3.select("div.span12").append("svg")
      .attr("width", width + margin.left + margin.right)
      .attr("height", height + margin.top + margin.bottom)
    .append("g")
      .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

  var layer = svg.selectAll(".layer")
      .data(layers)
    .enter().append("g")
      .attr("class", "layer")
      .style("fill", function(d, i) { return color(i); });

  var rect = layer.selectAll("rect")
      .data(function(d) { return d; })
    .enter().append("rect")
      .attr("x", 0)
      .attr("y", function(d, i, j) { return barHeight * j })
      .attr("width", function(d) { return x(d.x); })
      .attr("height", barHeight );

  var text = layer.selectAll("text")
      .data(function(d) { return d; })
    .enter().append("text")
      .style("text-anchor", "front")
      .style("fill", "#000")
      .attr("transform", function(d, i, j) { return "translate(10," + (barHeight * j + barHeight / 2) + ")" })
      .attr("class", "title")
      .text(function(d) { return d.title; });

  var xAxis = d3.svg.axis()
      .scale(x)
      .orient("top");

  svg.append("g")
      .attr("class", "x axis")
      .call(xAxis);
}

function calculateLayer(data) {
  // var a = [], i;
  // for (i = 0; i < data.length; ++i) {
  //   a[i] = data[i].value.duration
  // };
  // return a.map(function(d, i) { return {x: data[i]._id, y: d}; });

  return [{y: data.value.userId, x: data.value.duration, title: data.value.appPkg}]
}
// Inspired by Lee Byron's test data generator.
function bumpLayer(n, o) {

  function bump(a) {
    var x = 1 / (.1 + Math.random()),
        y = 2 * Math.random() - .5,
        z = 10 / (.1 + Math.random());
    for (var i = 0; i < n; i++) {
      var w = (i / n - y) * z;
      a[i] += x * Math.exp(-w * w);
    }
  }

  var a = [], i;
  for (i = 0; i < n; ++i) a[i] = o + o * Math.random();
  for (i = 0; i < 5; ++i) bump(a);
  console.log(a);
  return a.map(function(d, i) { return {x: i, y: Math.max(0, d)}; });
}