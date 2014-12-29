(function(){
	d3.json("/json/user_list.json", function(error, data) {
		d3.select("#users").selectAll("li").data(data).enter().append("li")
			.text(function(d) { return d.user; })
			.on("click", function(d) {

				document.getElementById("user-counts").innerHTML = "Nodes: " + d.nodes + "<br/>Ways: " + d.ways + "<br/>Relations: " + d.relations + "<br/>Changesets: " + d.changesets;
/*				d3.select("#user-counts").selectAll("span").data(
						[{"label": "Nodes", "count": d.nodes}, 
							{"label": "Ways", "count": d.ways}, 
							{"label": "Relations", "count": d.relations}, 
							{"label": "Changesets", "count": d.changesets}]).enter().append("span").text(function(d) { return d.label + ": " + d.count.toString() + "<br/>"; });
*/
				d3.json('/json/user_list_with_geometry/' + d.user + '.json', function(error, data) {
					if (typeof geojsonLayer != "undefined") { geojsonLayer.clearLayers(); }
					var myStyle = { "color": "#ff0000" };
					geojsonLayer = L.geoJson(data, {style: myStyle}).addTo(map);
				});
			});
	});
})();
