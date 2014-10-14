#
#
# Spec Helper
#
#

require_relative '../models/DomainObjects'
require_relative '../models/DatabaseConnection'

#Open connection to the test database
DatabaseConnection.new('test')