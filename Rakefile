# frozen_string_literal: true

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:test) do |t|
  t.rspec_opts = '--format documentation'
end

task :default => [:test]
