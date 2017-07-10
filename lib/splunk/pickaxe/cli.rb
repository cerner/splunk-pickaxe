# frozen_string_literal: true

require 'thor'
require 'etc'
require 'splunk/pickaxe'
require 'highline'

module Splunk
  module Pickaxe
    class CLI < Thor
      desc 'init', 'initializes your splunk repo'
      def init
        puts 'Creating Splunk Object directories...'
        [
          Alerts::DIR,
          Dashboards::DIR,
          EventTypes::DIR,
          Reports::DIR,
          Tags::DIR,
          FieldExtractions::DIR
        ].each do |dir|
          Dir.mkdir dir unless Dir.exist? dir
        end

        puts 'Writing Gemfile ...'
        File.open('Gemfile', 'w') do |f|
          f.puts 'source "https://rubygems.org"'
          f.puts
          f.puts 'gem "splunk-pickaxe"'
        end

        puts 'Writing .pickaxe.yml ...'
        File.open('.pickaxe.yml', 'w') do |f|
          f.puts 'namespace:'
          f.puts '  app: TODO'
          f.puts 'environments:'
          f.puts '  MY_ENV: SPLUNK_API_URL'
          f.puts 'emails:'
          f.puts '  - my.email@domain.com'
        end
      end

      desc 'sync ENVIRONMENT', 'sync your splunk repo to the given environment'
      option :user, type: :string, desc: 'The user to login to splunk with. If this is not provide it will use the current user'
      option :password, type: :string, desc: 'The password to login to splunk with. If this is not provided it will ask for a password'
      option :repo_path, type: :string, desc: 'The path to the repo. If this is not specified it is assumed you are executing from within the repo'
      def sync(environment)
        cli = HighLine.new

        user = options[:user] || Etc.getlogin
        password = options[:password] || cli.ask('Password: ') { |o| o.echo = '*' }
        execution_path = options[:repo_path] || Dir.getwd

        pickaxe = Pickaxe.configure environment, user, password, execution_path
        pickaxe.sync_all
      end
    end
  end
end
