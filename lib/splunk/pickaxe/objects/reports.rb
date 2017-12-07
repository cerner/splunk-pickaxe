# frozen_string_literal: true

require 'splunk/pickaxe/objects'
require 'splunk/pickaxe/objects/supported_keys'

module Splunk
  module Pickaxe
    class Reports < Objects
      DIR ||= 'reports'

      def splunk_resource
        %w[saved searches]
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

      def name(entity)
        # The report name contains the environment name
        "#{entity['name']} [#{environment.capitalize}]"
      end

      def splunk_config(entity_yaml)
        # Include default values
        config = report_defaults

        # Override defaults with any config provided in yaml
        config.merge! entity_yaml['config']

        config
      end

      def report_defaults
        {
          # Who to email
          'action.email.to' => pickaxe_config.config['emails'].join(','),

          # How often to run alert (every hour)
          'cron_schedule' => '0 * * * *',
          'is_scheduled' => '1',

          # Email subject
          'action.email.subject' => 'Splunk Report: $name$',
          'action.email.subject.alert' => 'Splunk Report: $name$',

          # Email result formatting (inline results, table format, include alert link)
          'action.email.format' => 'table',
          'action.email.inline' => '1',
          'action.email.include.view_link' => '1',

          # Send an email
          'actions' => 'email',
          'action.email.sendresults' => '1',

          # This is a report so always send it
          'alert_type' => 'always',

          # The time bounds for alert search (1 hour)
          'dispatch.earliest_time' => '-1h',
          'dispatch.latest_time' => 'now'
        }
      end

      def splunk_entity_keys
        Splunk::Pickaxe::REPORT_KEYS
      end
    end
  end
end
