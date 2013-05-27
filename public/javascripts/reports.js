function reports(reports) {
	// layer is appPkg
	// sample is user
	var n = reports.length,
			m = 1,
			stack = d3.layout.stack(),
			layers = stack(reports.map(function(d) { return calculateLayer(d); }));
	var yGroupMax = d3.max(layers, function(layer) { return d3.max(layer, function(d) { return d.y; }); }),
			yStackMax = d3.max(layers, function(layer) { return d3.max(layer, function(d) { return d.y0 + d.y; }); });
	var margin = {top: 40, right: 10, bottom: 20, left: 10},
			inset = {right: 150},
			width = 960 - margin.left - margin.right,
			height = 500 - margin.top - margin.bottom;

	var x = d3.scale.ordinal()
			.domain([reports[0].value.userId])
			.rangeRoundBands([0, width - inset.right], .08);

	var y = d3.scale.linear()
			.domain([0, yStackMax])
			.range([height, 0]);

	var color = d3.scale.linear()
			.domain([0, n - 1])
			.range(["#aad", "#556"]);

	var xAxis = d3.svg.axis()
			.scale(x)
			.tickSize(0)
			.tickPadding(6)
			.orient("bottom");

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
			.attr("x", function(d) { return x(d.x); })
			.attr("y", height)
			.attr("width", x.rangeBand())
			.attr("height", 0);

	rect.transition()
			.delay(function(d, i) { return i * 10; })
			.attr("y", function(d) { return y(d.y0 + d.y); })
			.attr("height", function(d) { return y(d.y0) - y(d.y0 + d.y); });

	svg.append("g")
			.attr("class", "x axis")
			.attr("transform", "translate(0," + height + ")")
			.call(xAxis);

	var legend = svg.selectAll(".legend")
			.data(reports.map(function(report) { return report.value.appPkg; }))
		.enter().append("g")
			.attr("class", "legend")
			.attr("transform", function(d, i) { return "translate(0," + i * 20 + ")"; });

	legend.append("rect")
			.attr("x", width - 18)
			.attr("width", 18)
			.attr("height", 18)
			.style("fill", function(d, i) { return color(i); });

	legend.append("text")
			.attr("x", width - 24)
			.attr("y", 9)
			.attr("dy", ".35em")
			.style("text-anchor", "end")
			.text(function(d) { return d; });

	d3.selectAll(".d3-button").on("click", change);

	var timeout = setTimeout(function() {
		d3.select("button[value=\"grouped\"]").classed("active", true).each(change);
		d3.select("button[value=\"stacked\"]").classed("active", false);
	}, 2000);

	function change() {
		clearTimeout(timeout);
		if (this.value === "grouped") transitionGrouped();
		else transitionStacked();
	}

	function transitionGrouped() {
		y.domain([0, yGroupMax]);

		rect.transition()
				.duration(500)
				.delay(function(d, i) { return i * 10; })
				.attr("x", function(d, i, j) { return x(d.x) + x.rangeBand() / n * j; })
				.attr("width", x.rangeBand() / n)
			.transition()
				.attr("y", function(d) { return y(d.y); })
				.attr("height", function(d) { return height - y(d.y); });
	}

	function transitionStacked() {
		y.domain([0, yStackMax]);

		rect.transition()
				.duration(500)
				.delay(function(d, i) { return i * 10; })
				.attr("y", function(d) { return y(d.y0 + d.y); })
				.attr("height", function(d) { return y(d.y0) - y(d.y0 + d.y); })
			.transition()
				.attr("x", function(d) { return x(d.x); })
				.attr("width", x.rangeBand());
	}
}

function calculateLayer(data) {
	// var a = [], i;
	// for (i = 0; i < data.length; ++i) {
	// 	a[i] = data[i].value.duration
	// };
	// return a.map(function(d, i) { return {x: data[i]._id, y: d}; });

	return [{x: data.value.userId, y: data.value.duration}]
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