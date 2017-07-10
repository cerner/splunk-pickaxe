require 'rspec'
require 'splunk/pickaxe'
require 'splunk/pickaxe/cli'

def splunk_object_classes
  constants = Splunk::Pickaxe.constants.select {|c| Splunk::Pickaxe.const_get(c).is_a? Class}
  # This needs to remove any other classes that are included in Pickaxe namespace
  constants = constants - [:Config, :Objects, :Client, :CLI]
  constants.map{ |c| Splunk::Pickaxe.const_get(c) }
end
