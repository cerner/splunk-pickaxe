require 'spec_helper'

describe Splunk::Pickaxe::CLI do
  subject { Splunk::Pickaxe::CLI.new }
  let(:file) { double('file') }

  context '#init' do
    before do
      splunk_object_classes.each do |clazz|
        allow(Dir).to receive(:mkdir).with(clazz.const_get(:DIR))
      end

      allow(File).to receive(:open).with(any_args).and_return(file)
      allow(subject).to receive(:puts).with(any_args)
    end

    it 'creates all object directories' do
      splunk_object_classes.each do |clazz|
        expect(Dir).to receive(:mkdir).with(clazz.const_get(:DIR))
      end

      subject.init
    end
  end

  context '#sync' do
    let(:options) do
      {
        user: 'my-user',
        password: 'my-password',
        repo_path: 'my-repo-path',
      }
    end
    let(:client) { double 'client' }
    let(:environment) { 'my-environment' }

    before do
      allow(subject).to receive(:options).and_return(options)
      allow(Splunk::Pickaxe).to receive(:configure).and_return(client)
    end

    it 'syncs the environment' do
      expect(Splunk::Pickaxe).to receive(:configure).with(environment, 'my-user', 'my-password', options)
      expect(client).to receive(:sync_all)

      subject.sync environment
    end
  end

  context '#save' do
    let(:options) do
      {
        user: 'my-user',
        password: 'my-password',
        repo_path: 'my-repo-path',
        overwrite: false
      }
    end
    let(:client) { double 'client' }
    let(:environment) { 'my-environment' }
    let(:overwrite) { false }

    before do
      allow(subject).to receive(:options).and_return(options)
      allow(client).to receive(:save_all)
      allow(Splunk::Pickaxe).to receive(:configure).and_return(client)
    end

    it 'calls configure on pickaxe' do
      expect(Splunk::Pickaxe).to receive(:configure).with(environment, 'my-user', 'my-password', options)

      subject.save environment
    end

    it 'calls save_all on client' do
      expect(client).to receive(:save_all)

      subject.save environment
    end
  end
end
