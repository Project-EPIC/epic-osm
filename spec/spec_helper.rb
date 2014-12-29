require_relative '../models/DomainObjects'
require_relative '../models/Persistence'
require_relative '../models/Query'

require 'debugger'

#Open connection to a test database:
#DatabaseConnection.new(database: 'philippines', host: 'epic-analytics.cs.colorado.edu', port: 27018)
DatabaseConnection.new(database: 'nic-test')
