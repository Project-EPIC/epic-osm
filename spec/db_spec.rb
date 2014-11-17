require 'yaml'
require_relative '../models/DatabaseConnection.rb'

describe DatabaseConnection do

	it "Can connect to the local test database" do
		DatabaseConnection.new
		puts DatabaseConnection.database.inspect
	end

	it "Can connect to the server production database" do
		DatabaseConnection.new(host: 'epic-analytics.cs.colorado.edu', database: 'philippines', port: 27018)
		puts DatabaseConnection.database.inspect
	end

end