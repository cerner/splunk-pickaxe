# frozen_string_literal: true

require 'yaml'
require 'splunk/pickaxe/objects'

module Splunk
  module Pickaxe
    class EventTypes < Objects
      DIR ||= 'eventtypes'

      def splunk_resource
        %w[saved eventtypes]
      end

      def entity_dir
        DIR
      end
    end
  end
end
