# frozen_string_literal: true

require 'splunk/pickaxe/objects'

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
    end
  end
end
