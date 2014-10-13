require 'yaml'
require_relative '../models/DatabaseConnection.rb'

describe DatabaseConnection do
	it "Can connect to the Database" do
		connect = DatabaseConnection.new
		puts connect.inspect
	end
end