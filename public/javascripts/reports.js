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
			width = 960 - margin.left - margin.right,
			height = 500 - margin.top - margin.bottom;

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
			.attr("y", function(d, i, j) { return (y.rangeBand() / n) * j })
			.attr("width", function(d) { return x(d.x); })
			.attr("height", y.rangeBand() / n );

	var text = layer.selectAll("text")
			.data(function(d) { return d; })
		.enter().append("text")
			.style("text-anchor", "front")
			.style("fill", "#000")
			.attr("transform", function(d, i, j) { barHeight = y.rangeBand() / n; return "translate(10," + (barHeight * j + barHeight / 2) + ")" })
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
	// 	a[i] = data[i].value.duration
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