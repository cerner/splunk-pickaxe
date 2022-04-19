# frozen_string_literal: true

require 'splunk/pickaxe/objects/alerts'
require 'splunk/pickaxe/objects/dashboards'
require 'splunk/pickaxe/objects/eventtypes'
require 'splunk/pickaxe/objects/macros'
require 'splunk/pickaxe/objects/reports'
require 'splunk/pickaxe/objects/tags'
require 'splunk/pickaxe/objects/field_extractions'

module Splunk
  module Pickaxe
    class Client
      attr_reader :service, :alerts, :dashboards, :eventypes, :macros, :reports, :tags, :field_extractions

      def initialize(service, environment, config, args)
        @service = service
        @args = args

        @alerts = Alerts.new service, environment, config
        @dashboards = Dashboards.new service, environment, config
        @eventtypes = EventTypes.new service, environment, config
        @macros = Macros.new service, environment, config
        @reports = Reports.new service, environment, config
        @tags = Tags.new service, environment, config
        @field_extractions = FieldExtractions.new service, environment, config
      end

      def sync_all
        @macros.sync
        @field_extractions.sync
        @alerts.sync
        @dashboards.sync
        @eventtypes.sync
        @reports.sync
        @tags.sync
      end

      def save_all
        overwrite = @args.fetch(:overwrite, false)
        local_save = @args.fetch(:local_save, false)

        @alerts.save overwrite, local_save
        @dashboards.save overwrite, local_save
        @eventtypes.save overwrite, local_save
        @macros.save overwrite, local_save
        @reports.save overwrite, local_save
        # splunk-sdk doesn't seem to support iterating tags
        @field_extractions.save overwrite, local_save
      end
    end
  end
end
