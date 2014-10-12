Import Scripts
=============================
The first import script **read_pbf** will parse the PBF file and create the nodes, ways, and relations collections in the database.  The last two scripts will gather data from these collections in order to build the changesets and users collections.


###read_pbf.rb
	Call this in the following manner: 
		ruby read_pbf.rb [database name] [pbf file]
		Optional arguments include: limit=, port=, and host=




###import_changesets.rb
	Usage: ruby import_changesets.rb -d DATABASE -c COLLECTION  [-l LIMIT]
		Iterate over a collection and hit the API for the changeset information.

	Specific options:
	    -d, --database Database Name     Name of Database (Haiti, Philippines)
	    -c, --Collection Name            Type of OSM object (nodes, ways, relations)
	    -l, --limit [LIMIT]              [Optional] Limit of objects to parse
	    -h, --help                       Show this message

This script performs an **upsert** on the changeset collection for a given database.  It collects changesets from the nodes/ways/relations collections and then hits the API for the details of that changeset.



###import_users.rb
	Usage: ruby import_users.rb -d DATABASE  [-l LIMIT]
		This will import users specifically from the changesets found in the desired database
	
	Specific options:
	    -d, --database Database Name     Name of Database (Haiti, Philippines)
	    -l, --limit [LIMIT]              [Optional] Limit of users to parse
	    -h, --help                       Show this message

This script performs an **upsert** on the user collection for a given database.  It collects users from the changesets collection and then hits the api for each one, upsetting their details to the Mongo collection.

