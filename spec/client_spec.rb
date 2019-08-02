require 'spec_helper'

describe Splunk::Pickaxe::Client do
  let(:service) { double 'service' }
  let(:environment) { 'my-environment' }
  let(:config) { double 'config' }
  let(:class_to_double) do
    Hash[splunk_object_classes.collect { |clazz| [clazz, double] }]
  end
  subject { Splunk::Pickaxe::Client }

  before do
    splunk_object_classes.each do |clazz|
      allow(clazz).to receive(:new).and_return(class_to_double[clazz])
    end
  end

  context '#new' do
    let(:args) { { user: 'user', password: 'pass' } }
    it 'calls #new on all objects' do
      splunk_object_classes.each do |clazz|
        expect(clazz).to receive(:new).with(service, environment, config)
      end

      subject.new(service, environment, config, args)
    end
  end

  context '#sync_all' do
    let(:args) { { user: 'user', password: 'pass' } }
    subject { Splunk::Pickaxe::Client.new(service, environment, config, args) }

    it 'calls #sync on all objects' do
      splunk_object_classes.each do |clazz|
        expect(class_to_double[clazz]).to receive(:sync)
      end

      subject.sync_all
    end
  end

  context '#save_all' do
    let(:args) { { user: 'user', password: 'pass', overwrite: false } }
    let(:classes) { splunk_object_classes.reject { |clazz| clazz == Splunk::Pickaxe::Tags } }
    subject { Splunk::Pickaxe::Client.new(service, environment, config, args) }

    it 'calls #save on all objects except tag' do
      classes.each do |clazz|
        expect(class_to_double[clazz]).to receive(:save).with(false, false)
      end

      subject.save_all
    end

    context 'when overwrite and local_save are not in args' do
      let(:args) { { user: 'user', password: 'pass' } }
      subject { Splunk::Pickaxe::Client.new(service, environment, config, args) }

      it 'calls #save with false' do
        classes.each do |clazz|
          expect(class_to_double[clazz]).to receive(:save).with(false, false)
        end

        subject.save_all
      end

      context 'when overwrite is in args' do
        let(:args) { { user: 'user', password: 'pass', overwrite: true } }
        subject { Splunk::Pickaxe::Client.new(service, environment, config, args) }

        it 'calls #save with overwrite\'s value' do
        classes.each do |clazz|
          expect(class_to_double[clazz]).to receive(:save).with(true, false)
        end

        subject.save_all
        end
      end

      context 'when local_save is in args' do
        let(:args) { { user: 'user', password: 'pass', local_save: true } }
        subject { Splunk::Pickaxe::Client.new(service, environment, config, args) }

        it 'calls #save with overwrite\'s value' do
        classes.each do |clazz|
          expect(class_to_double[clazz]).to receive(:save).with(false, true)
        end

        subject.save_all
        end
      end

      context 'when overwrite and local_save are in args' do
        let(:args) { { user: 'user', password: 'pass', overwrite: true, local_save: true } }
        subject { Splunk::Pickaxe::Client.new(service, environment, config, args) }

        it 'calls #save with overwrite\'s value' do
        classes.each do |clazz|
          expect(class_to_double[clazz]).to receive(:save).with(true, true)
        end

        subject.save_all
        end
      end
    end
  end
end
