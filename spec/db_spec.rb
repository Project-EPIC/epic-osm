require 'yaml'
require_relative '../models/DatabaseConnection.rb'

describe DatabaseConnection do
	it "Can connect to the local test database" do
		connect = DatabaseConnection.new(env: 'test')
		puts connect.inspect
	end

	it "Can connect to the server production database" do
		connect = DatabaseConnection.new(env: 'production')
		puts connect.inspect
	end
end