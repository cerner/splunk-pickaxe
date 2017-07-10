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
    end
  end
end
