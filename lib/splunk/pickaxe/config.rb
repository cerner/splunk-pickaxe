# frozen_string_literal: true

require 'yaml'

module Splunk
  module Pickaxe
    class Config
      CONFIG_FILE ||= '.pickaxe.yml'

      DEFAULTS ||= {
        'namespace' => {
          'sharing' => 'app'
        },
        'environments' => {
        },
        'emails' => [],
      }.freeze

      def self.load(environment, execution_path)
        config_path = File.join(execution_path, CONFIG_FILE)
        raise "Unable to load config file [#{config_path}]" unless File.exist? config_path

        # Merges DEFAULTS with yaml config
        Config.new deep_merge(DEFAULTS, YAML.load_file(config_path)), environment, execution_path
      end

      attr_reader :namespace, :environment, :execution_path, :emails, :url, :env_config

      def initialize(config, environment, execution_path)
        raise "Config must have a 'namespace / app' config" unless config['namespace'].key?('app')
        raise "Environment [#{environment}] is not configured" unless config['environments'].has_key?(environment)

        @execution_path = execution_path
        @environment = environment

        env_config = config['environments'][environment]

        if env_config.is_a?(String)
          # Support this for now to be passive but we will remove it later
          puts "Your .pickaxe.yml is using a deprecated config format. Check https://github.com/cerner/splunk-pickaxe#backwards-compatibility for details"
          @emails = config['emails']
          @url = env_config
          @env_config = { 'url' => @url, 'emails' => @emails }
        elsif env_config.is_a?(Hash)
          raise "url config is required for environment [#{environment}]" unless env_config.has_key?('url')
          @url = env_config['url']
          @emails = env_config.has_key?('emails') ? env_config['emails'] : config['emails']
          @env_config = env_config
        else
          raise "Unexpected value for environment [#{environment}] config. Expected String or Hash, saw #{config['environments'][environment]}"
        end

        # Convert namespace config hash to hash with symbols for keys
        namespace_config = config['namespace'].each_with_object({}) { |(k, v), memo| memo[k.to_sym] = v; }
        @namespace = Splunk.namespace(namespace_config)
      end

      private

      # Simple deep merge of two hashes
      def self.deep_merge hash1, hash2
        copy = Hash[hash1]

        hash2.each do |key, value|
          if value.kind_of?(Hash) && hash1[key].kind_of?(Hash)
            copy[key] = deep_merge(hash1[key], value)
          else
            copy[key] = value
          end
        end

        copy
      end
    end
  end
end
