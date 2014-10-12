require 'mongo'
require 'date'

db = 'haiti'

#mongo_conn = Mongo::MongoClient.new('epic-analytics.cs.colorado.edu','27018')
mongo_conn = Mongo::MongoClient.new
DB = mongo_conn[db]


def insert_to_mongo(uid, payload)
	DB['users'].update(
		{"uid" => uid}, {'$set' => payload}, 
		opts={:upsert=>true})
end

def parse_date(date_to_parse)
	return Time.new(date_to_parse).utc
end


#Actual Insert Code

fake_date = parse_date("2012-01-01")
fake_user = {:joining_date=>fake_date, :name=>'Blah blah'}

insert_to_mongo(12345, fake_user)