#!/bin/bash

#disable SSL verification on Git:
git config --global http.sslVerify false

echo "Building Protobuf 2.6.0 & Protobuf-C"
ldconfig
cd /home/osmhistory/protobuf-2.6.0
./autogen.sh
./configure
make install -w
clear

echo "Installing OSM-Binary Headers"
ldconfig
cd /home/osmhistory/OSM-binary-master
make -C src install
clear


echo "Building OSMIUM"
ldconfig
cd /home/osmhistory/osmium-master
make -w install
clear

echo "Now running Osmium Tests: Should have 27 successes and 1 failure"
make test

echo "Building osm-history-splitter"
ldconfig
cd /home/osmhistory/osm-history-splitter-master
make clean
make install

echo "Now Running osm-history-splitter test"
./osm-history-splitter test/version-two-node-after.osh test/test.config

ldconfig

echo "Now installing Ruby Gems without documentation"

echo "Skipping a clean ruby Install"
#zypper --non-interactive --gpg-auto-import-keys in ruby-devel

gem install bundler --no-ri --no-rdoc
gem install mongo --no-ri --no-rdoc
gem install bson --no-ri --no-rdoc
gem install bson_ext --no-ri --no-rdoc
gem install pbf_parser --no-ri --no-rdoc
gem install rgeo --no-ri --no-rdoc
gem install nori --no-ri --no-rdoc
gem install nokogiri -v 1.5.0 --no-ri --no-rdoc

echo "Now cloning the latest version of osm-history2 and configuring for this environment"
cd /home/osmhistory/
git clone https://github.com/rsoden/osm-history2
cd osm-history2
echo "osm-history-splitter: /home/osmhistory/osm-history-splitter-master/osm-history-splitter" > config.yml

echo "Starting MongoDB..."
/etc/init.d/mongodb start