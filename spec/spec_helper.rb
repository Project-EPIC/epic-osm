#Add the project root for absolute pathing
$:.unshift File.expand_path('.')

require 'models/DomainObjects'
require 'models/Persistence'
require 'models/Query'

require 'epic-osm'
require 'debugger'


#Open connection to a test database:
#DatabaseConnection.new(database: 'philippines', host: 'epic-analytics.cs.colorado.edu', port: 27018)
#DatabaseConnection.new(database: 'boulder-history')
