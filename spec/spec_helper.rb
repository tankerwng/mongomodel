require 'rubygems'
require 'spec'

# Require MongoModel library
require File.dirname(__FILE__) + '/../lib/mongomodel'

# Require spec helpers
Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each { |f| require f }

Spec::Runner.configure do |config|
  include SpecsFor
  include DefineClass
  
  config.before(:all) do
    MongoModel.configuration = { 'database' => 'mongomodel-specs' }
  end
  
  config.before(:each) do
    MongoModel.database.collections.each { |c| c.remove }
  end
end
