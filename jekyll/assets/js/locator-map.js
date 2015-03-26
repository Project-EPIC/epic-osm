---
---
var map = L.map('map').setView([0, 0], 2);
        L.tileLayer('https://{s}.tiles.mapbox.com/v3/{id}/{z}/{x}/{y}.png', {
            maxZoom: 18,
            attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, ' +
        '<a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, ' +
        'Imagery © <a href="http://mapbox.com">Mapbox</a>',
            id: 'examples.map-i875mjb7'
        }).addTo(map);
        var bbox = {{ site.data.bbox_geojson_geometry | jsonify }};
        L.geoJson(bbox).addTo(map);
        var bounds = L.geoJson(bbox).getBounds();
        map.fitBounds(bounds);
var geojsonLayer;
