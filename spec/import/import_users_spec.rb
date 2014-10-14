require 'spec_helper'

require_relative '../../import_scripts/osm_api/import_users'

describe UserImport do
	before :each do
		@user_import = UserImport.new
	end

	it "can get all distinct users in nodes, ways, relations db" do 
		puts @user_import.distinct_uids.length
	end

	it "Can import users" do 
		@user_import.import_user_objects
	end
end