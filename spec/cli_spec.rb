require 'spec_helper'

describe Splunk::Pickaxe::CLI do

  let(:cli) { Splunk::Pickaxe::CLI.new }
  let(:file) { double('file') }

  context '#init' do
    before(:each) do
      splunk_object_classes.each do |clazz|
        allow(Dir).to receive(:mkdir).with(clazz.const_get(:DIR))
      end

      allow(File).to receive(:open).with(any_args).and_return(file)
      allow(cli).to receive(:puts).with(any_args)
    end

    it 'should create all object directories' do
      splunk_object_classes.each do |clazz|
        expect(Dir).to receive(:mkdir).with(clazz.const_get(:DIR))
      end

      cli.init
    end
  end

  context '#sync' do
    let(:options) { {:user => 'my-user', :password => 'my-password', :repo_path => 'my-repo-path' } }
    let(:client) { double 'client' }
    let(:environment) { 'my-environment' }

    before(:each) do
      allow(cli).to receive(:options).and_return(options)
      allow(Splunk::Pickaxe).to receive(:configure).with(any_args).and_return(client)
    end

    it 'should sync the environment' do
      expect(Splunk::Pickaxe).to receive(:configure).with(environment, 'my-user', 'my-password', 'my-repo-path')
      expect(client).to receive(:sync_all)

      cli.sync environment
    end
  end
end
