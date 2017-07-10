# frozen_string_literal: true

require 'yaml'
require 'splunk/pickaxe/objects'

module Splunk
  module Pickaxe
    class Tags < Objects
      DIR ||= 'tags'

      def splunk_resource
        %w[search tags]
      end

      def entity_dir
        DIR
      end

      # Tags do not follow the typical conventions that other splunk resources do
      # so we have to change the find/create/update methods
      def find(entity)
        # Either return the entity or nil if it doesn't exist

        response = service.request(method: :GET, resource: splunk_resource + [name(entity)])
        # Parse out fields
        atom_feed = Splunk::AtomFeed.new(response.body)
        atom_feed.entries.map { |e| e['title'] }
      rescue Splunk::SplunkHTTPError => e
        if e.code == 404
          nil
        else
          raise e
        end
      end

      def create(entity)
        # Create and update are the same thing. Pass in no known fields
        update [], entity
      end

      def update(splunk_entity, entity)
        # what we want - whats there = what we need to create/update
        (splunk_config(entity) - splunk_entity).each do |field|
          response = service.request(method: :POST, resource: splunk_resource + [name(entity)], body: { add: field })
          raise "Failed to add field to tag [#{response.code}] - [#{response.body}]" unless response.is_a? Net::HTTPSuccess
        end

        # whats there - what we want = what we need to remove
        (splunk_entity - splunk_config(entity)).each do |field|
          response = service.request(method: :POST, resource: splunk_resource + [name(entity)], body: { delete: field })
          raise "Failed to delete field from tag [#{response.code}] - [#{response.body}]" unless response.is_a? Net::HTTPSuccess
        end
      end

      def splunk_config(entity)
        entity['fields']
      end

      def needs_update?(splunk_entity, entity)
        # Compares the fields in our config vs whats in splunk
        splunk_config(entity).uniq.sort != splunk_entity.uniq.sort
      end
    end
  end
end
