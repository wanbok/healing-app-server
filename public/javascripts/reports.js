Array.prototype.remove = function(from, to) {
  var rest = this.slice((to || from) + 1 || this.length);
  this.length = from < 0 ? this.length + from : from;
  return this.push.apply(this, rest);
};

function correlate() {
  var xAxisMenu = ['하루평균사용시간(ms)', '하루평균앱실행횟수(회)'];
  var xAxisSelected = xAxisMenu[0]
  var yAxisMenu = ['설문점수', '일평균추정사용시간(시)'];
  var yAxisSelected = yAxisMenu[0]
  var mergedData = [];
  var margin = {top: 20, right: 20, bottom: 30, left: 40},
      width = 800 - margin.left - margin.right,
      height = 800 - margin.top - margin.bottom;

  var x = d3.scale.linear()
      .range([0, width]);

  var y = d3.scale.linear()
      .range([height, 0]);

  var dotSize = 8;

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

  //Build menus
  d3.select('#x-axis-menu')
    .selectAll('button')
    .data(xAxisMenu)
    .enter()
    .append('button')
    .classed('btn d3-button', true)
    .classed('active', function(d){
      return d === xAxisSelected;
    })
    .text(function(d){return d;})
    .on('click', function(d) {
      xAxisSelected = d;
      updateChart(mergedData);
      // updateMenus();
    });

  d3.select('#y-axis-menu')
    .selectAll('button')
    .data(yAxisMenu)
    .enter()
    .append('button')
    .classed('btn d3-button', true)
    .classed('active', function(d){
      return d === yAxisSelected;
    })
    .text(function(d){return d;})
    .on('click', function(d) {
      yAxisSelected = d;
      updateChart(mergedData);
      // updateMenus();
    })

  function updateScaleDomain(data) {
    if (data != null) {
      x.domain(d3.extent(data, function(d) { return d[xAxisSelected]; })).nice();
      y.domain(d3.extent(data, function(d) { return d[yAxisSelected]; })).nice();
    } else {
      maxForX = xAxisSelected === xAxisMenu[0] ? 24*60*60*1000 : 1000;
      x.domain(d3.extent([0, maxForX], function(d) { return d; })).nice();
      maxForY = yAxisSelected === yAxisMenu[0] ? 60 : 24;
      y.domain(d3.extent([0, maxForY], function(d) { return d; })).nice();
    };
  }

  function updateChart(data) {
    updateScaleDomain(data);
    d3.select('svg g.chart')
      .selectAll('circle')
      .transition()
      .duration(500)
      .ease('quad-out')
      .attr('cx', function(d) {
        return x(d[xAxisSelected]);
      })
      .attr('cy', function(d) {
        return y(d[yAxisSelected]);
      })
      .attr('r', function(d) {
        return dotSize;
      });

    d3.select('#xAxis')
      .transition()
      .call(xAxis);

    d3.select('#xLabel')
      .text(xAxisSelected);

    d3.select('#yAxis')
      .transition()
      .call(yAxis);

    d3.select('#yLabel')
      .text(yAxisSelected);

    updateCorrelation(data);
    drawExtraCorrelation(data, "M");
    drawExtraCorrelation(data, "F");
  }

  function drawBackground(data) {
    updateScaleDomain(data);

    svg.append("g")
        .attr("id", "xAxis")
        .classed("axis", true)
        .attr("transform", "translate(0," + height + ")")
        .call(xAxis)
      .append("text")
        .attr("id", "xLabel")
        .attr("x", width)
        .attr("y", -6)
        .style("text-anchor", "end")
        .text(xAxisSelected);

    svg.append("g")
        .attr("id", "yAxis")
        .classed("axis", true)
        .call(yAxis)
      .append("text")
        .attr("id", "yLabel")
        .attr("transform", "rotate(-90)")
        .attr("y", 6)
        .attr("dy", ".71em")
        .style("text-anchor", "end")
        .text(yAxisSelected);

    d3.select('svg g.chart')
      .append('text')
      .attr({'id': 'userLabel', 'x': 0, 'y': 170})
      .style({'font-size': '20px', 'font-weight': 'bold', 'fill': '#ddd'});

    d3.select('svg g.chart')
      .append('line')
      .attr('id', 'allBestfit');
      
    d3.select('svg g.chart')
      .append('line')
      .attr('id', 'mBestfit');
      
    d3.select('svg g.chart')
      .append('line')
      .attr('id', 'fBestfit');
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

  function updateCorrelation(data) {
    var xArray = _.map(data, function(d) {return d[xAxisSelected];});
    var yArray = _.map(data, function(d) {return d[yAxisSelected];});
    var c = getCorrelation(xArray, yArray);
    var x1 = x.domain()[0], y1 = c.m * x1 + c.b;
    var x2 = x.domain()[1], y2 = c.m * x2 + c.b;

    d3.select('svg g.chart #allBestfit')
      .style('opacity', 0)
      .attr({'x1': x(x1), 'y1': y(y1), 'x2': x(x2), 'y2': y(y2)})
      .transition()
      .duration(1500)
      .style('opacity', 1);
  }

  function drawExtraCorrelation(rawData, type) {
    var data = _.reduce(rawData, function(m, v, i) {
      v.survey.sex === type ? m.push(v) : null;
      return m;
    }, []);
    var xArray = _.map(data, function(d) {return d[xAxisSelected];});
    var yArray = _.map(data, function(d) {return d[yAxisSelected];});
    var c = getCorrelation(xArray, yArray);
    var x1 = x.domain()[0], y1 = c.m * x1 + c.b;
    var x2 = x.domain()[1], y2 = c.m * x2 + c.b;

    d3.select("svg g.chart #"+type.toLowerCase()+"Bestfit")
      .style('opacity', 0)
      .attr({'x1': x(x1), 'y1': y(y1), 'x2': x(x2), 'y2': y(y2)})
      .transition()
      .duration(1500)
      .style('stroke', color(type))
      .style('opacity', 1);
  }

  function changeDescription(d) {
    var description = d.survey.user + ", ";
    if (xAxisSelected === xAxisMenu[0]) {
      description += "X: 약" + Math.round(d[xAxisSelected] / (60*60*1000)) +
        "시간(" + d[xAxisSelected] + "), "
    } else if (xAxisSelected === xAxisMenu[1]) {
      description += "X: 약" + d[xAxisSelected] + "회, "
    };
    description += "Y: " + d[yAxisSelected];
    d3.select('svg g #userLabel')
      .text(description)
      .transition()
      .style('opacity', 1);
  }

  function applyData(data) {
    updateScaleDomain(data);
    updateChart(data);
    svg.selectAll(".dot")
        .data(data)
      .enter().append("circle")
        .attr("id", function(d) { return d.survey.user; })
        .attr("class", "dot")
        .attr("r", dotSize)
        .attr("cx", function(d) { return x(d[xAxisSelected]); })
        .attr("cy", function(d) { return y(d[yAxisSelected]); })
        .style("fill", function(d) { return color(d.survey.sex); })
        .style('cursor', 'pointer')
        .on('mouseover', changeDescription)
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
  }

  function pullData(index) {
    d3.json("/correlate.json", function(error, data) {
      data.forEach(function(d){
        var userId = d.value.userId.replace(/\+82/, "0");
        var result = $.grep(mergedData, function(dd) { return dd.survey.user === userId;});
        if (result.length > 0) {
          result[0].measuredData = d.value;
          result[0][xAxisMenu[0]] = Math.round(d.value.nomalizedUsageDurationPerDay);
          result[0][xAxisMenu[1]] = Math.round(d.value.nomalizedAppChangingCountPerDay);
        }
      });
      $.each(mergedData, function(i){       // 지워진 데이터로 인해 인덱스가 밀리는 현상이 없도록 $.each 함수를 사용함.
        if(typeof(mergedData[i]) === 'undefined' || typeof(mergedData[i].measuredData) === 'undefined') {
          mergedData.remove(i);
        }
      });
      applyData(mergedData);
    });
  }

  function surveys() {
    d3.json("http://wanbok.com/surveys.json", function(error, data) {
      console.log("Survey count: " + data.length);
      data.forEach(function(d){
        d.survey.user = d.survey.user.replace(/-/gi, "");
        d[yAxisMenu[0]] = d.aggregation.total;
        d[yAxisMenu[1]] = d.survey.usage_duration_per_day;
      });
      mergedData = data
      pullData();
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