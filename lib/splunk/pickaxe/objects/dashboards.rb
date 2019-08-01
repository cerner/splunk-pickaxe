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
        template = IO.read(file_path)
        xml_content = ERBWithBinding::render_from_hash(template, pickaxe_config.env_config)

        # Dashboards don't have many properties just name and source XML
        {
          'name' => File.basename(file_path, '.xml'),
          'config' => {
            'eai:data' => xml_content
          }
        }
      end

      def entity_file_extensions
        ['.xml']
      end

      def save_config(splunk_entity, overwrite, local_save)
        file_path = entity_file_path splunk_entity

        if local_save
          if File.exist?(file_path)
            puts "- #{splunk_entity['label']}"
            write_to_file(file_path, overwrite, splunk_entity)
          end
        else
          puts "- #{splunk_entity['label']}"
          write_to_file(file_path, overwrite, splunk_entity)
        end
      end

      def write_to_file(file_path, overwrite, splunk_entity)
        if overwrite || !File.exist?(file_path)
          overwritten = overwrite && File.exist?(file_path)

          File.write(file_path, splunk_entity['eai:data'])
          puts overwritten ? '  Overwritten' : '  Created'
        else
          puts '  Already exists'
        end
      end
    end
  end
end
