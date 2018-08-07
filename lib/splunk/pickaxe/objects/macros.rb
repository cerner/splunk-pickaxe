# frozen_string_literal: true

require 'yaml'
require 'splunk/pickaxe/objects'
require 'splunk/pickaxe/objects/supported_keys'

module Splunk
  module Pickaxe
    class Macros < Objects
      DIR ||= 'macros'

      def splunk_resource
        %w[admin macros]
      end

      def entity_dir
        DIR
      end

      def entity_file_path(splunk_entity)
        File.join(
          pickaxe_config.execution_path, entity_dir,
          entity_file_name(splunk_entity)
        )
      end

      def splunk_entity_keys
        Splunk::Pickaxe::MACRO_KEYS
      end
    end
  end
end
