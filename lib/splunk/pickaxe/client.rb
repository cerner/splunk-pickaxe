# frozen_string_literal: true

require 'splunk/pickaxe/objects/alerts'
require 'splunk/pickaxe/objects/dashboards'
require 'splunk/pickaxe/objects/eventtypes'
require 'splunk/pickaxe/objects/reports'
require 'splunk/pickaxe/objects/tags'
require 'splunk/pickaxe/objects/field_extractions'

module Splunk
  module Pickaxe
    class Client
      attr_reader :service, :alerts, :dashboards, :eventypes, :reports, :tags, :field_extractions

      def initialize(service, environment, config)
        @service = service

        @alerts = Alerts.new service, environment, config
        @dashboards = Dashboards.new service, environment, config
        @eventtypes = EventTypes.new service, environment, config
        @reports = Reports.new service, environment, config
        @tags = Tags.new service, environment, config
        @field_extractions = FieldExtractions.new service, environment, config
      end

      def sync_all
        @alerts.sync
        @dashboards.sync
        @eventtypes.sync
        @reports.sync
        @tags.sync
        @field_extractions.sync
      end

      def save_all
        @alerts.save
        @dashboards.save
        @eventtypes.save
        @reports.save
        # splunk-sdk doesn't seem to support iterating tags
        @field_extractions.save
      end
    end
  end
end
