# frozen_string_literal: true

require 'splunk/pickaxe/objects'

module Splunk
  module Pickaxe
    class Dashboards < Objects
      DIR ||= 'dashboards'

      def splunk_resource
        %w[data ui views]
      end

      def entity_dir
        DIR
      end

      def entity_file_name(entity)
        "#{entity['label']}.xml".gsub(/[^a-z0-9_\-. ]/i, '')
                                .tr(' ', '_')
      end

      def entity_file_path(splunk_entity)
        File.join(
          pickaxe_config.execution_path, entity_dir,
          entity_file_name(splunk_entity)
        )
      end

      def config(file_path)
        # Dashboards don't have many properties just name and source XML
        {
          'name' => File.basename(file_path, '.xml'),
          'config' => {
            'eai:data' => IO.read(file_path)
          }
        }
      end

      def entity_file_extensions
        ['.xml']
      end

      def save_config(splunk_entity)
        file_path = entity_file_path splunk_entity

        puts "- #{splunk_entity['label']}"
        if File.exist? file_path
          puts '  Already exists'
        else
          File.write(file_path, splunk_entity['eai:data'])
          puts '  Created'
        end
      end
    end
  end
end
