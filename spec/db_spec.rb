require 'yaml'
require_relative '../models/DatabaseConnection.rb'

describe DatabaseConnection do

	it "Can connect to the local test database" do
		DatabaseConnection.new('test')
		puts DatabaseConnection.database.inspect
	end

	it "Can connect to the server production database" do
		DatabaseConnection.new
		puts DatabaseConnection.database.inspect
	end

end