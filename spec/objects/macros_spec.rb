require 'spec_helper'

describe Splunk::Pickaxe::Macros do
  let(:service) { double 'service' }
  let(:environment) { 'my-environment' }
  let(:pickaxe_config) { double 'pickaxe_config' }
  let(:service_namespace) { double 'service_namespace' }
  let(:execution_path) { 'execution_path' }
  let(:subject) { Splunk::Pickaxe::Macros.new service, environment, pickaxe_config }

  before do
    allow(service).to receive(:namespace).and_return(service_namespace)
    allow(pickaxe_config).to receive(:execution_path).and_return(execution_path)
    allow(subject).to receive(:puts).with(any_args)
  end

  context '#save_config' do
    let(:entity) { double 'entity' }
    let(:file_path) { double 'file_path' }
    let(:entity_config) do
      {
        'definition' => 'some:definition',
        'disabled' => '1'
      }
    end
    let(:expected_entity_config) do
      {
        'definition' => 'some:definition',
        'disabled' => '1'
      }
    end

    before do
      allow(subject).to receive(:entity_file_path).and_return(file_path)
      allow(entity).to receive(:name).and_return('entity name')
      allow(File).to receive(:exist?).and_return(false)
      allow(File).to receive(:write)

      subject.splunk_entity_keys.each do |k|
        allow(entity).to receive(:fetch).with(k).and_return(entity_config[k])
      end
    end

    context 'when the file exists' do
      it 'will not write the config' do
        allow(File).to receive(:exist?).and_return(true)
        expect(File).to_not receive(:write)

        subject.save_config(entity, false, false)
      end

      context 'and overwrite is true' do
        it 'writes to config' do
          allow(File).to receive(:exist?).and_return(true)
          expect(File).to receive(:write)

          subject.save_config(entity, true, false)
        end
      end

      context 'and local_save is passed' do
        it 'does not write the config' do
          allow(File).to receive(:exist?).and_return(true)
          expect(File).to_not receive(:write)

          subject.save_config(entity, false, true)
        end
      end

      context 'when overwrite and local_save are passed' do
        it 'writes the config' do
          allow(File).to receive(:exist?).and_return(true)
          expect(File).to receive(:write)

          subject.save_config(entity, true, true)
        end
      end
    end

    context 'when the file does not exist' do
      it 'calls fetch on all keys' do
        subject.splunk_entity_keys.each do |k|
          expect(entity).to receive(:fetch).with(k).and_return(entity_config[k])
        end

        subject.save_config(entity, false, false)
      end

      it 'writes transformed config to the file' do
        expect(File).to receive(:write).with(file_path, {
          'name' => 'entity name',
          'config' => expected_entity_config
        }.to_yaml)

        subject.save_config(entity, false, false)
      end

      context 'and local_save is passed' do
        it 'does not write the config' do
          expect(File).to_not receive(:write)

          subject.save_config(entity, false, true)
        end
      end
    end
  end
end
