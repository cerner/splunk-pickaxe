# frozen_string_literal: true

require 'splunk-sdk-ruby'
require 'yaml'

# Base class for syncing splunk objects (dashboards, alerts, etc...)
module Splunk
  module Pickaxe
    class Objects
      attr_reader :service, :environment, :pickaxe_config

      def initialize(service, environment, pickaxe_config)
        @service = service
        @environment = environment
        @pickaxe_config = pickaxe_config
      end

      def sync
        puts "Syncing all #{entity_dir.capitalize}"

        dir = File.join(pickaxe_config.execution_path, entity_dir)

        unless Dir.exist? dir
          puts "The directory #{dir} does not exist. Not syncing #{entity_dir.capitalize}"
          return
        end

        Dir.entries(dir).each do |entity_file|
          entity_path = File.join(dir, entity_file)

          next unless File.file?(entity_path) && entity_file_extensions.any? { |ext| entity_path.end_with?(ext) }

          entity = config(entity_path)
          entity_name = name(entity)

          puts "- #{entity_name}"

          # Check if we should skip this entity
          if skip? entity
            puts '  Skipping'
            next
          end

          splunk_entity = find entity

          if splunk_entity.nil?
            # Entity does not exist create it
            puts '  Creating ...'
            create entity
            puts '  Created!'
          else
            # Entity exists check if it needs an update
            if needs_update? splunk_entity, entity
              puts '  Updating ...'
              update splunk_entity, entity
              puts '  Updated!'
            else
              puts '  Up to date!'
            end
          end
        end
      end

      def config(file_path)
        YAML.load_file file_path
      end

      def create(entity)
        entity_collection = Splunk::Collection.new service, splunk_resource
        entity_collection.create(name(entity), splunk_config(entity))
      end

      def update(splunk_entity, entity)
        splunk_entity.update(splunk_config(entity))
      end

      def find(entity)
        # Either return the entity or nil if it doesn't exist

        Splunk::Entity.new service, service.namespace, splunk_resource, name(entity)
      rescue Splunk::SplunkHTTPError => e
        if e.code == 404
          nil
        else
          raise e
        end
      end

      def needs_update?(splunk_entity, entity)
        splunk_config(entity).each do |k, v|
          return true if splunk_entity[k] != v
        end

        false
      end

      def skip?(entity)
        return false unless entity.key?('envs')
        !entity['envs'].include?(environment)
      end

      def name(entity)
        entity['name']
      end

      def splunk_config(entity)
        entity['config']
      end

      def entity_file_extensions
        ['.yml', '.yaml']
      end

      def splunk_resource
        # Must be implemented by child class
        nil
      end

      def entity_dir
        # Must be implemented by child class
        nil
      end
    end
  end
end
