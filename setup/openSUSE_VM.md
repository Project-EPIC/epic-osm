OSM OpenSUSE Virtual Machine
============================
There is a [virtual machine image available for download from susestudio.org](https://susestudio.com/a/ukxbT7/osmhistory_opensuse_13_1). 

The repository owners are attempting to maintain this machine for quick deployment of a development / research environment for this project.

#Running Install Script
To get the machine up and running, run the script located here: 
https://gist.github.com/jenningsanderson/8b3a590e4662e0fc27eb

There is a script which automatically clones this script located in ```/root/get_install.sh```

If Git does not clone it properly, run: ```git config --global http.sslVerify false```

This should allow you to clone the script properly. It will automatically copy it to ```/home/osmhistory/install.sh```

Password for both root and osmhistory is “osm”

Now you can just run ```/home/osmhistory/install.sh``` and the machine should build itself...

#Enabling Shared Folders:
In virtualbox, setup a shared folder pointing to your osm-history2 directory (or parent directory).

Then install guest tools with:

	zypper in virtualbox-ose-guest-tools

Ignore the repositories that don't have it with (i), once installed, run this to activate it:

	modprobe vboxsf

Make a folder you want to link: 
	
	mkdir /home/share

To mount the folder do:
	
	mount -t vboxsf {name of folder} /home/share

The host folder now appears at /home/share/  You can use the host for editing, version control, etc, and then just switch over to the VM for running tests and scripts.

To have this done automagically, put the following lines into ```/etc/init.d/after.local```
	
	modprobe vboxsf
	mount -t vboxsf {name of folder} /home/share

	/etc/init.d/mongodb start


##Before you can shutdown the machine, be sure to run ```mongod --shutdown``` as root!  Then you can run ```shutdown now``` to power off the machine


#First Time Startup: Manually

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
