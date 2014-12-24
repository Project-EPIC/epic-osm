OSM History Analysis Tool
=========================

[Project EPIC](http://epic.cs.colorado.edu) 2014.

##About
Who mapped where, when, and with whom?


##Installation
The **setup** directory contains instructions for installing the development environment on both Mac OS X and a specific build of an OpenSUSEx64 Virtual Machine.  The machine is hosted on susestudio.org and the developers are making an effort to support that VM.

##Running
Inside the **analysis_window** directory are a series of YAML configuration files.  These files define _analysis windows_, the area that the user is interested in studying.  Defining both temporal and geographical bounds are important.  See ```sample-awconfig.yml``` for an example.

There are a series of rake tasks available, most important is ```rake new```

	rake cleanup            # Clean up all temp files
	rake cut                # Write appropriate configuration file and 	cut the file to c...
	rake import:changesets  # Import Changesets
	rake import:pbf         # Import PBF File (Nodes, Ways, Relations)
	rake import:users       # Import Users
	rake network            # Network Writers
	rake new                # Given a valid configuration file, Cut and Import all of th...
	rake questions:nodes    # Run Node Questions

##Motivations
Some of the questions we aim to be able to answer:

###V1 Questions:
1. Top contributors (per analysis window)
	a. 	What's the metric here?  nodes, changesets, what makes an active user?
	
2. Recent edits
	a. Again, what's the metric? Nodes, changesets, etc?
	b. Returns geometries for visualization

3. POI count
	a. What defines a point of interest.
	b. Weekly/Monthly buckets

4. Length of Ways
	a. Rivers, roads, etc.
	b. Weekly/Monthly buckets

5. Building Count
	a. Especially tasks which
	b. Weekly/Monthly buckets

6. Within temporally adjacent / overlapping changesets, identify users that worked in close geographic proximity
