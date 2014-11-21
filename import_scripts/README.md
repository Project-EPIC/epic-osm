Import Scripts
=============================

##import_analysis_window.rb
This file is a driver which kicks off the pbf import as well as the changeset and user imports which hit the OSM API.

The best way to call it is with one of the rake functions, such as ```rake new``` or ```rake import:users```


##pbf_to_mongo.rb
This is the only place where the PBF parser gem is required.  The ```OSMPBF``` class in this script will open a .osm.pbf file and import each node, way, relation to MongoDB for a given analysis window.

It will only import data up to the ```end_date``` parameter in the analysis window configuration file.  It will, however, import data from the earliest point in the .osm.pbf file.