# frozen_string_literal: true

require 'splunk/pickaxe/objects'
require 'splunk/pickaxe/objects/supported_keys'

module Splunk
  module Pickaxe
    class FieldExtractions < Objects
      DIR ||= 'field_extractions'

      def splunk_resource
        %w[data props extractions]
      end

      def entity_dir
        DIR
      end

      def entity_file_name(splunk_entity)
        "#{splunk_entity['stanza']}-#{splunk_entity['type']}-#{splunk_entity['attribute']}.yml"
          .gsub(/[^a-z0-9_\-. ]/i, '')
      end

      def entity_file_path(splunk_entity)
        File.join(
          pickaxe_config.execution_path, entity_dir,
          entity_file_name(splunk_entity)
        )
      end

      def find(entity)
        # Splunk does some fun things by re-naming our field extraction to include
        # the stanza and type in the name when its created so do that here by
        # cloning the entity and editing its name before passing it to find
        find_entity = Hash.new(entity)
        find_entity['name'] = "#{entity['config']['stanza']} : #{entity['config']['type']}-#{entity['name']}"
        super(find_entity)
      end

      def update(splunk_entity, entity)
        # When updating splunk only wants the value field
        splunk_entity.update('value' => splunk_config(entity)['value'])
      end

      def needs_update?(splunk_entity, entity)
        # When updating splunk only cares about this field
        splunk_entity['value'] != splunk_config(entity)['value']
      end

      def save_config(splunk_entity, overwrite, local_save)
        file_path = entity_file_path splunk_entity

        if local_save
          if File.exist?(file_path)
            puts "- #{splunk_entity.name}"
            write_to_file(file_path, overwrite, splunk_entity)
          end
        else
          puts "- #{splunk_entity.name}"
          write_to_file(file_path, overwrite, splunk_entity)
        end
      end

      def write_to_file(file_path, overwrite, splunk_entity)
        if overwrite || !File.exist?(file_path)
          config = splunk_entity_keys
                   .map { |k| { k => splunk_entity.fetch(k) } }
                   .reduce({}) { |memo, setting| memo.update(setting) }
          # the POST api expects 'type' to be the first part of 'attribute'
          # while the GET api returns 'type' within 'attribute'
          # the GET api also command and space delimits values, it should only
          # use commas OR spaces.
          config['type'] = splunk_entity.fetch('attribute').split('-').first
          config['value'].gsub!(/, /, ',')

          overwritten = overwrite && File.exist?(file_path)
          File.write(file_path, {
            'name' => splunk_entity.name,
            'config' => config
          }.to_yaml)
          puts overwritten ? '  Overwritten' : '  Created'
        else
          puts '  Already exists'
        end
      end

      def splunk_entity_keys
        Splunk::Pickaxe::FIELD_EXTRACTIONS_KEYS
      end
    end
  end
end
