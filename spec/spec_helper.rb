#
#
# Spec Helper
#
#

require_relative '../models/DomainObjects'
require_relative '../models/DatabaseConnection'
require_relative '../models/Query'

#Open connection to the test database
DatabaseConnection.new('test')