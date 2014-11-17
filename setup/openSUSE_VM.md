OSM OpenSUSE Virtual Machine
============================
There is a [virtual machine image available for download from susestudio.org](https://susestudio.com/a/ukxbT7/osmhistory_opensuse_13_1). 

The repository owners are attempting to maintain this machine for quick deployment of a development / research environment for this project.

This seems to be relatively stable thus far -- However, when things become completely stable, this will be integrated into a first-boot script.


#First Time Startup

(Latest update: These apply to current VM version 1.3.14)
##Tools & Environment

####Gain Root access:
	su
Current password is 'osm'

####Enable Shared Library
	export LD_LIBRARY_PATH=/usr/local/lib

####Disable SSL Verification on Git:
	git config --global http.sslVerify false
	
####Install protobuf 2.6.0 from source: 
	cd /home/osmhistory/protobuf-2.6.0
	./autogen.sh
	./configure
	make && make install

####Build protobuf-c from source:
	cd /home/osmhistory/protobuf-c-master

	ldconfig

	./autogen.sh
	./configure	
	make && make install
		
####Install the OSM-Binary headers: 
	cd /home/osmhistory/OSM-binary-master
	cd src
	make && make install

####Build Osmium: 

	cd /home/osmhistory/osmium-master
	make install
	
Optionally, run tests

	test/run_tests.sh 
	
27 ok, 0 compile error, 1 fail
	
####Install osm-history-splitter

	cd /home/osmhistory/osm-history-splitter-master
	make clean
	make install


##Ruby
Perform a new install of Ruby with zypper, this seems to enable Ruby to find the previously installed headers easier...

	zypper in ruby-devel

It will scream about not finding ruby in the first two repositories it searches, use ```i``` to ignore, then ```y``` to install when it finds it...

###Install Gems: 

	gem install bundler
	gem install mongo
	gem install bson
	gem install bson_ext
	gem install pbf_parser
	gem install rgeo
	gem install nori

	gem install nokogiri -v 1.5.0

(Will find appropriate versions of these gems to lock them in -- also, not entirely sure bundler is necessary because it's not working as it should...)

#Running the Server

##Start Mongo
	/etc/init.d/mongodb start
	
This should be integrated into a startup script.
	
#Running the Application

Unfortunately, the version of osm-history2 which is in the VM is configured for ssh, so first delete it, then reclone it.

	cd /home/osmhistory
	rm -r osm-history2
	git clone https://github.com/rsoden/osm-history2.git
	cd osm-history2

##Import a new file?
	rake new analysis_windows/nic_test.yml
