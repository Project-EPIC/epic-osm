Mac OS X Mavericks
==================

I am going to attempt to document every step required to get osm-history2 up and running on a clean install of Mavericks

###1. Install the install tools
Install [homebrew](http://brew.sh).  Easy to do from terminal with:

	$ ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

This process will also walk you through installing command-line tools for Xcode.


Next install git and mongodb:

	$ brew install git
	$ brew install mongodb
	
To test mongodb, launch a server ````$ sudo mongod````.  If this fails, you probably need to make a ````/data/db```` directory for mongo to use.  Once this is done, you should be able to connect to it with ````$ mongo```
	
	
###2. The Tools


The main tool we need, osm-history-splitter, has many dependencies: 

###Osmium
[Osmium Github Repository](https://github.com/joto/osmium).  I did not test each of these, I just installed them all just to be safe.

	$ brew install boost
	$ brew install lzlib
	$ brew install shapelib
	$ brew install libgd
	$ brew install gdal

At this point, brew had some questions about my Python installation, I followed the instructions provided by brew to put Homebrew's site-packages into the sys.path used by Python.

I also modified my ```$PATH``` to put ```/usr/local/bin``` before ```/usr/bin``` so that Homebrew's links ran before system defaults.  (This was prompted by ```brew doctor```)
	
*I do not know if ````libgd```` actually did what I think it did... but it didn't break anything _yet_, so I'm rolling with it.

	$ brew install expat

Mac OS X already has expat 1.5, so I had to ```brew link --force expat``` to override it.

	$ brew install geos 	# => geos-3.4.2 already installed

I suppose this is good -- probably happened with GDAL.

	$ brew install google-sparsehash
	$ brew install v8

This *may* install an incompatible version of v8 for osmium, but it's working thus far... so rolling with it.

	$ brew install protobuf-c
	$ brew install doxygen
	
Next, **OSM-Binary** is required.  Nothing fancy here, just clone the repository and follow the instructions found in the README (copied below)

	$ git clone https://github.com/scrosby/OSM-binary.git
	$ cd OSM-Binary
	$ make -C src
	$ make -C src install

At this point, I attempted to install Osmium (per instructions in the README)

	$ git clone https://github.com/joto/osmium.git
	$ cd osmium
	$ sudo make install
	$ make clean

Run the tests?

	$ cd test
	$ ./run_tests.sh
	
I had 27 tests ok and 1 compile error, I think it was a BOOST error, and I did not install libboost-test, so we'll just assume that's what happened...


###3. osm-history-splitter
Now that dependencies are installed, lets install osm-history-splitter

	$ git clone https://github.com/MaZderMind/osm-history-splitter.git
	$ cd osm-history-splitter
	$ make
	
Run tests: 

	$ ./osm-history-splitter test/version-two-node-after.osh test/test.config

It ran!

###4. osm-history2

	$ git clone https://github.com/rsoden/osm-history2.git
	
Setup: 

	$ cd osm-history2
	$ cp sample-config.yml config.yml

1. Update the location of your osm-history-splitter tool in the config file.


###Ruby
	$ sudo gem install bundler
	$ bundle install
	
This may crash, if it does, then you should just install each gem by hand.  I think the issue here lies with the bundler not being able to find the appropriate header files which we just spent so much time installing.

I did the following things as troubleshooting steps, somewhere in there, something worked:

```$ brew info protobuf-c``` showed it was missing ```pkg-config```, so I ```$ brew install pkg-config```

I then over-rode system Ruby (probably a good idea anyways)

	$ brew install rbenv

Follow those instructions, updated to Ruby 2.1.3, hoping it would force all gems to see new header files.

Fail, downgrade to previous dev environment: _2.0.0p247_

	$ rbenv install 2.0.0-p247
	$ rbenv global 2.0.0
	
	
In the event the bundler is unable to handle each of the previous gems, you now have a better ruby version manager and can begin the fun gem install process...
	
	$ gem install mongo
	$ gem install bson
	$ gem install bson_ext
	$ gem install rgeo
	$ gem install nori
	$ gem install nokogiri
	$ gem install rspec
	$ gem install debugger
	
Ultimately, clone from _github.com/planas/pbf_parser_ and then gem build ```pbf_parser.gemspec``` and then ```gem install pbf_parser```.  This worked for me... hope it works for you!



OSM OpenSUSE Virtual Machine
============================

#First Time Startup

##Tools & Environment

####Enable Shared Library
	export LD_LIBRARY_PATH=/usr/local/lib

####Gain Root access:

	su (osm)

####Disable SSL Verification on Git:

	git config --global http.sslVerify false
	
####Install protobuf 2.6.0 from source: 

	cd /home/osmhistory/protobuf-2.6.0-master
	./autogen.sh
	./configure
	make
	make install
	
####Build protobuf-c from source:

	cd /home/osmhistory/protobuf-c-master
	./autogen.sh
	./configure	make
	make install
	
####Install the OSM-Binary headers: 

	cd /home/osmhistory/OSM-binary-master
	cd src
	make install

####Build Osmium: 

	cd /home/osmhistory/osmium-master
	make install
	
	test/run_tests.sh 
	
####Install osm-history-splitter

	cd /home/osmhistory/osm-history-splitter-master
	make clean
	make install


##Ruby

Attempting a new install of Ruby with zypper
	
	zipper in ruby-devel
	
Yes, this works!

###Install Gems: 

	gem install bundler
	gem install mongo
	gem install bson
	gem install bson_ext
	gem install pbf_parser
	gem install rgeo
	gem install nori

	gem install nokogiri -v 1.5.0

	
#Running the Server

##Start Mongo
	/etc/init.d/mongo start
	
	
#Running the Application

	cd /home/osmhistory/osm-history2

##Import a new file?
	rake new analysis_windows/nic_test.yml

