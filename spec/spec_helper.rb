#
#
# Spec Helper
#
#
require 'mongo'

require_relative '../models/DomainObjects'
require_relative '../models/DatabaseConnection'

DatabaseConnection.new('test')

if __FILE__ == $0
	build_database
end