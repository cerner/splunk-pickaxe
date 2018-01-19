# frozen_string_literal: true

require 'yaml'
require 'splunk/pickaxe/objects'
require 'splunk/pickaxe/objects/supported_keys'

module Splunk
  module Pickaxe
    class Alerts < Objects
      DIR ||= 'alerts'

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
        # The alert name contains the environment name
        "#{entity['name']} [#{environment.capitalize}]"
      end

      def splunk_config(entity_yaml)
        # Include default values
        config = alert_defaults

        # Override defaults with any config provided in yaml
        config.merge! entity_yaml['config']

        config
      end

      def alert_defaults
        {
          # Who to email
          'action.email.to' => pickaxe_config.emails.join(','),

          # How often to run alert (every hour)
          'cron_schedule' => '0 * * * *',
          'is_scheduled' => '1',

          # Email subject
          'action.email.subject' => 'Splunk Alert: $name$',
          'action.email.subject.alert' => 'Splunk Alert: $name$',

          # Email result formatting (inline results, table format, include alert link)
          'action.email.format' => 'table',
          'action.email.inline' => '1',
          'action.email.include.view_link' => '1',

          # Is an email alert
          'actions' => 'email',
          'action.email.sendresults' => '1',

          # Alert severity (High)
          'alert.severity' => '4',

          # When to trigger alert
          'alert_type' => 'number of events',
          'alert_comparator' => 'greater than',
          'alert_threshold' => '0',

          # The time bounds for alert search
          'dispatch.earliest_time' => '-1h',
          'dispatch.latest_time' => 'now',

          # Track alerts
          'alert.track' => '1',

          # Don't supress any alerts
          'alert.suppress' => '0'
        }
      end

      def splunk_entity_keys
        Splunk::Pickaxe::ALERT_KEYS
      end
    end
  end
end
