# frozen_string_literal: true

require 'ostruct'

module Splunk
  module Pickaxe
    class ERBWithBinding < OpenStruct
      def self.render_from_hash(t, h)
        ERBWithBinding.new(h).render(t)
      end

      def render(template)
        ERB.new(template).result(binding)
      end
    end
  end
end
