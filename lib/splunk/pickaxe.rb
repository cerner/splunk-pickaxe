# frozen_string_literal: true

require 'splunk-sdk-ruby'
require 'uri'
require 'splunk/pickaxe/config'
require 'splunk/pickaxe/client'
require 'splunk/pickaxe/cookie_proxy'

module Splunk
  module Pickaxe
    def self.configure(environment, username, password, args)
      config = Config.load(environment, args.fetch(:repo_path, Dir.getwd))

      raise "Unknown environment [#{environment}]. Expected #{config.environments.keys}" unless config.environments.key?(environment)

      uri = URI(config.url)

      puts "Connecting to splunk [#{uri}]"
      service = Splunk.connect(
        proxy: CookieProxy,
        scheme: uri.scheme.to_sym,
        host: uri.host,
        port: uri.port,
        username: username,
        password: password,
        namespace: config.namespace
      )

      Client.new service, environment.downcase, config, args
    end
  end
end
