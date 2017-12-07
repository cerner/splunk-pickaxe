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
        'emails' => []
      }.freeze

      def self.load(execution_path)
        config_path = File.join(execution_path, CONFIG_FILE)
        raise "Unable to load config file [#{config_path}]" unless File.exist? config_path

        # Merges DEFAULTS with yaml config
        Config.new deep_merge(DEFAULTS, YAML.load_file(config_path)), execution_path
      end

      attr_reader :config, :namespace, :environments, :execution_path

      def initialize(config, execution_path)
        unless config['namespace'].key? 'app'
          raise "Config must have a 'namespace / app' config"
        end

        raise "Must have at least one environment" unless config['environments'].size > 0

        @config = config
        @execution_path = execution_path

        @environments = config['environments']

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
