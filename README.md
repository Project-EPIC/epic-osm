OSM History Analysis Tool
=========================

[Project EPIC](http://epic.cs.colorado.edu) 2014.

##About




##Development Questions
A running tally of questions that we have as we develop

1. Database Connection
	-	Currently we mocked the database to connect to the existing Mongo instance for Haiti and return a simple hash called "database".  The question is whether to use a tool like Mongoid or MongoMapper to link our classes directly to the Mongo Instance, or whether we should write our own wrapper since our queries will be relatively simple from the Mongo standpoint.
		- However if we have a Containers or Bounding Box collection, we would probably want to interact with it in such a way (i.e. have the ability to save / update.)
		
2. How should we handle Geo Objects?  Should the domain object itself inherit from RGeo?  Should we use RGeo? yes.
3. What is best practice: super(args) vs. post_initialize?



##Development Questions: October 5, 2014

1. Finalize version 1 questions and then refactor the code.

2. Running new import script on server (and to create local offline copies)


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

