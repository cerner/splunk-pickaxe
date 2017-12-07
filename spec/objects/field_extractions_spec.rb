require 'spec_helper'

describe Splunk::Pickaxe::FieldExtractions do
  let(:service) { double 'service' }
  let(:environment) { 'my-environment' }
  let(:pickaxe_config) { double 'pickaxe_config' }
  let(:service_namespace) { double 'service_namespace' }
  let(:execution_path) { 'execution_path' }
  let(:subject) { Splunk::Pickaxe::FieldExtractions.new service, environment, pickaxe_config }

  before do
    allow(service).to receive(:namespace).and_return(service_namespace)
    allow(pickaxe_config).to receive(:execution_path).and_return(execution_path)
    allow(subject).to receive(:puts).with(any_args)
  end

  context '#entity_file_name' do
    context 'when the passed entity has only valid characters' do
      let(:entity) { double 'entity' }

      it 'returns an extension with stanza, type, and attribute' do
        allow(entity).to receive(:[]).with('stanza').and_return('stanza')
        allow(entity).to receive(:[]).with('type').and_return('type')
        allow(entity).to receive(:[]).with('attribute').and_return('attribute')

        expect(subject.entity_file_name(entity)).to eq('stanza-type-attribute.yml')
      end
    end

    context 'when the passed entity has invalid characters' do
      let(:entity) { double 'entity' }

      it 'returns entity[\'label\'] without the invalid characters' do
        allow(entity).to receive(:[]).with('stanza').and_return('stanza-.')
        allow(entity).to receive(:[]).with('type').and_return('ty_+/pe')
        allow(entity).to receive(:[]).with('attribute').and_return('attribute*_ ')

        expect(subject.entity_file_name(entity)).to eq('stanza-.-ty_pe-attribute_ .yml')
      end
    end
  end

  context '#save_config' do
    let(:entity) { double 'entity' }
    let(:file_path) { double 'file_path' }
    let(:entity_config) do
      {
        'attribute' => 'REPORT-some-fields',
        'value' => 'thisindex, thatindex',
        'type' => 'inline',
        'stanza' => 'some:stanza'
      }
    end
    let(:expected_entity_config) do
      {
        'stanza' => 'some:stanza',
        'type' => 'REPORT',
        'value' => 'thisindex,thatindex'
      }
    end

    before do
      allow(subject).to receive(:entity_file_path).and_return(file_path)
      allow(entity).to receive(:name).and_return('entity name')
    end

    context 'when the file exists' do
      it 'does not write the config' do
        allow(File).to receive(:exist?).and_return true
        expect(File).to_not receive(:write)

        subject.save_config(entity)
      end
    end

    context 'when the file does not exist' do
      before do
        allow(File).to receive(:exist?).and_return false
        allow(File).to receive(:write)
        allow(entity).to receive(:fetch).with('attribute')
                                        .and_return(entity_config['attribute'])
        subject.splunk_entity_keys.each do |k|
          allow(entity).to receive(:fetch).with(k).and_return(entity_config[k])
        end
      end

      it 'calls fetch on all keys' do
        subject.splunk_entity_keys.each do |k|
          expect(entity).to receive(:fetch).with(k).and_return(entity_config[k])
        end

        subject.save_config(entity)
      end

      it 'writes transformed config to the file' do
        expect(File).to receive(:write).with(file_path, {
          'name' => 'entity name',
          'config' => expected_entity_config
        }.to_yaml)

        subject.save_config(entity)
      end
    end
  end
end
