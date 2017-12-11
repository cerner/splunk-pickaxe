# frozen_string_literal: true
require "rubygems"
require 'rspec/core/rake_task'

REPO = 'cerner/splunk-pickaxe'

RSpec::Core::RakeTask.new(:test) do |t|
  t.rspec_opts = '--format documentation'
end

task :default => [:test]

task :release do
  intialize_octokit
  puts "Releasing the gem ..."

  spec = Gem::Specification::load("splunk-pickaxe.gemspec")
  version = spec.version.to_s

  # Update change log
  puts "Updating change log ..."
  update_change_log version
  puts "Change log updated!"

  puts "Publishing the gem ..."
  run_command 'gem build splunk-pickaxe.gemspec'
  run_command "gem push splunk-pickaxe-#{version}.gem"
  run_command "rm -f splunk-pickaxe-#{version}.gem"
  puts "Gem published!"

  puts "Creating git tag ..."
  run_command "git tag #{version}"
  run_command "git push origin #{version}"
  puts "Git tag created!"

  puts "Updating to next version ..."
  update_version version
  puts "Version updated!"

  puts "Gem released!"
end

task :build_change_log do
  intialize_octokit
  closed_milestones = @octokit.milestones REPO, {:state => "closed"}

  version_to_milestone = Hash.new
  versions = Array.new

  closed_milestones.each do |milestone|
    version = Gem::Version.new(milestone.title)
    version_to_milestone.store version, milestone
    versions.push version
  end

  versions = versions.sort.reverse

  change_log = File.open('CHANGELOG.md', 'w')

  begin
    change_log.write "Change Log\n"
    change_log.write "==========\n"
    change_log.write "\n"

    versions.each do |version|
      milestone = version_to_milestone[version]
      change_log.write generate_milestone_markdown(milestone)
      change_log.write "\n"
    end
  ensure
    change_log.close
  end
end

def intialize_octokit
  require 'octokit'
  if ENV['GITHUB_API_TOKEN']
    @octokit = Octokit::Client.new(:access_token => ENV['GITHUB_API_TOKEN'])
  else
    @octokit = Octokit::Client.new
  end
end

def update_change_log version
  change_log_lines = IO.read(File.join(File.dirname(__FILE__), 'CHANGELOG.md')).split("\n")

  change_log = File.open('CHANGELOG.md', 'w')

  begin

    # Keep change log title
    change_log.write change_log_lines.shift
    change_log.write "\n"
    change_log.write change_log_lines.shift
    change_log.write "\n"
    change_log.write "\n"

    # Write new milestone info
    change_log.write generate_milestone_markdown(milestone(version))

    # Add previous change log info
    change_log_lines.each do |line|
      change_log.write line
      change_log.write "\n"
    end

  ensure
    change_log.close
  end

  run_command "git add CHANGELOG.md"
  run_command "git commit -m 'Added #{version} to change log'"
  run_command "git push origin HEAD"
end

def generate_milestone_markdown milestone
  strings = Array.new

  title = "[#{milestone.title} - #{milestone.updated_at.strftime("%m-%d-%Y")}](https://github.com/#{REPO}/issues?milestone=#{milestone.number}&state=closed)"

  strings.push "#{title}"
  strings.push "-" * title.length
  strings.push ""

  issues = @octokit.issues REPO, {:milestone => milestone.number, :state => "closed"}

  issues.each do |issue|
    strings.push "  * [#{issue_type issue}] [Issue-#{issue.number}](https://github.com/#{REPO}/issues/#{issue.number}) : #{issue.title}"
  end

  strings.push ""

  strings.join "\n"
end

def milestone version
  closedMilestones = @octokit.milestones REPO, {:state => "closed"}

  closedMilestones.each do |milestone|
    if milestone["title"] == version
      return milestone
    end
  end

  openMilestones = @octokit.milestones REPO

  openMilestones.each do |milestone|
    if milestone["title"] == version
      return milestone
    end
  end

  raise "Unable to find milestone with title [#{version}]"
end

def issue_type issue
  labels = Array.new
  issue.labels.each do |label|
    labels.push label.name.capitalize
  end
  labels.join "/"
end

def run_command command
  output = `#{command}`
  unless $?.success?
    raise "Command : [#{command}] failed.\nOutput : \n#{output}"
  end
end

def update_version version
  version_splits = version.split('.')
  version_splits[1] = (version_splits[1].to_i + 1).to_s
  next_version = version_splits.join('.')

  version_rb = IO.read('lib/splunk/pickaxe/version.rb')
  new_version_rb = version_rb
    .split("\n")
    .map{|line| line.include?('VERSION =') ? "    VERSION = '#{next_version}'" : line }
    .join("\n")

  File.write('lib/splunk/pickaxe/version.rb', new_version_rb)

  run_command "git add lib/splunk/pickaxe/version.rb"
  run_command "git commit -m 'Updated version to #{next_version}'"
  run_command "git push origin HEAD"
end
