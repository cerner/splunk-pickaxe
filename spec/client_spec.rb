require 'spec_helper'

describe Splunk::Pickaxe::Client do
  let(:service) { double 'service' }
  let(:environment) { 'my-environment' }
  let(:config) { double 'config' }
  let(:subject) { Splunk::Pickaxe::Client }
  let(:class_to_double) do
    Hash[splunk_object_classes.collect { |clazz| [clazz, double] }]
  end

  before(:each) do
    splunk_object_classes.each do |clazz|
      allow(clazz).to receive(:new).and_return(class_to_double[clazz])
    end
  end

  context '#new' do
    it 'calls #new on all objects' do
      splunk_object_classes.each do |clazz|
        expect(clazz).to receive(:new).with(service, environment, config)
      end

      subject.new(service, environment, config)
    end
  end

  context '#sync_all' do
    let(:subject) { Splunk::Pickaxe::Client.new(service, environment, config) }

    it 'calls #sync on all objects' do
      splunk_object_classes.each do |clazz|
        expect(class_to_double[clazz]).to receive(:sync)
      end

      subject.sync_all
    end
  end

  context '#save_all' do
    let(:subject) { Splunk::Pickaxe::Client.new(service, environment, config) }

    it 'calls #save on all objects except tag' do
      splunk_object_classes
        .reject { |clazz| clazz == Splunk::Pickaxe::Tags }.each do |clazz|
        expect(class_to_double[clazz]).to receive(:save)
      end

      subject.save_all
    end
  end
end
