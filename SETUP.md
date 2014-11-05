OSM History Setup
=====

Unfortunately, the Dependencies for this project are fairly massive and unruly.  This is due to the complexities of dealing with PBF files as well as the OSM-history-splitter tool.  We aim to maintain a virtual image which is always in functioning order and available for download.

##Dependencies
The Gemfile contains mostly explicit versioning information which has worked thus far.  For specific instances, it pulls directly from GitHub sources.  The developers will make a continual effort to keep the Gemfile updated with fully-functional gem versions.  To take advantage of this, use Ruby's Bundler gem:

There are 3 environments: ```default```, ```import```, and ```test```.  To be able to do everything, perform a bundle install, note that you will need to have PBF parsing dependencies (see below) in place before this will succeed:

	bundle install
	
If you do not need import capabilities, consider using:

	bundle install --without import

This will ignore the ```pbf_parser``` dependencies and allow you to point at an existing MongoDB database for analysis.

###Database
1. MongoDB

At this time, we are exclusively using MongoDB.  Given the Key/Value Pair nature of OSM data, a document store such as MongoDB makes sense.  Mongo also has reasonable geo-spatial query abilities.

###PBF File Parsing
Required for Importing OSM data to Mongo

	$ brew install lzlib
	$ brew install protobuf-c
	
From [Planas/pbf_parser](https://github.com/planas/pbf_parser).  The ```pbf_parser``` gem is included in the Gemfile.

####PBF File Cutting
In order to cut analysis windows out of PBF files, the [osm-history-splitter tool from GitHub user MaZderMind is required](https://github.com/MaZderMind/osm-history-splitter).  There are many dependencies which are outlined on the Repository page.

We recommend using [homebrew](http://brew.sh/) for most of these dependencies if developing on a Mac.  You may need to ```brew link --force [FORMULAE]``` on some of the libraries in order to override outdated system libraries.

####Homebrew Options:

For Mongo:

	$ brew install mongodb

For PBF Parser

	$ brew install lzlib
	$ brew install protobuf-c

For OSM-History-Splitter

	$ brew install geos
	$ brew install expat
	$ brew install libxml2


###Resources
- [homebrew](http://brew.sh/)
- [MongoDB](http://www.mongodb.org/downloads)
- [PBF_Parser](https://github.com/planas/pbf_parser)
- [OSM-history-splitter](https://github.com/MaZderMind/osm-history-splitter)