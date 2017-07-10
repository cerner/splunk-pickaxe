# frozen_string_literal: true

require 'splunk-sdk-ruby'
require 'uri'
require 'splunk/pickaxe/config'
require 'splunk/pickaxe/client'

module Splunk
  module Pickaxe
    def self.configure(environment, username, password, execution_path = Dir.getwd)
      config = Config.load execution_path

      raise "Unknown environment [#{environment}]. Expected #{config.environments.keys}" unless config.environments.key?(environment)

      uri = URI(config.environments[environment])

      puts "Connecting to splunk [#{uri}]"
      service = Splunk.connect(
        scheme: uri.scheme.to_sym,
        host: uri.host,
        port: uri.port,
        username: username,
        password: password,
        namespace: config.namespace
      )

      Client.new service, environment.downcase, config
    end
  end
end
