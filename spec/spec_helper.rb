require 'rspec'
require 'splunk/pickaxe'
require 'splunk/pickaxe/cli'

def splunk_object_classes
  constants = Splunk::Pickaxe.constants.select {|c| Splunk::Pickaxe.const_get(c).is_a? Class}
  constants = constants.map { |c| Splunk::Pickaxe.const_get(c) }

  # This removes any other classes that are included in Pickaxe namespace
  constants.select { |c| c < Splunk::Pickaxe::Objects }
end
