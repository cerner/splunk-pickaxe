require 'spec_helper'

describe Splunk::Pickaxe::Objects do

  let(:service) { double 'service' }
  let(:service_namespace) { double 'service_namespace' }
  let(:environment) { 'my-environment' }
  let(:pickaxe_config) { double 'pickaxe_config' }
  let(:execution_path) { 'execution_path' }

  class TestObjects  < Splunk::Pickaxe::Objects
    def splunk_resource
      %w[resource]
    end

    def entity_dir
      'my-dir'
    end
  end

  let(:subject) { TestObjects.new service, environment, pickaxe_config }

  before(:each) do
    allow(service).to receive(:namespace).and_return(service_namespace)
    allow(pickaxe_config).to receive(:execution_path).and_return(execution_path)
    allow(subject).to receive(:puts).with(any_args)
  end

  context '#sync' do

    let(:entity) { {'name' => 'entity-name', 'config' => {'key' => 'value'}} }
    let(:splunk_collection) { double 'splunk_collection' }

    before(:each) do
      entity_dir = File.join(execution_path, 'my-dir')
      entity_path = File.join(entity_dir, 'my-entry.yml')
      allow(Dir).to receive(:exist?).with(entity_dir).and_return(true)
      allow(Dir).to receive(:entries).with(entity_dir).and_return(['my-entry.yml'])
      allow(File).to receive(:file?).with(entity_path).and_return(true)
      allow(YAML).to receive(:load_file).with(entity_path).and_return(entity)
      allow(Splunk::Collection).to receive(:new).with(service, ['resource']).and_return(splunk_collection)
    end

    context 'entity does not exist' do

      it 'should create the entity' do
        expect(Splunk::Entity).to receive(:new).with(any_args).and_return(nil)
        expect(splunk_collection).to receive(:create).with(entity['name'], entity['config'])

        subject.sync
      end
    end

    context 'entity exists' do

      before(:each) do
        allow(Splunk::Entity).to receive(:new).with(any_args).and_return(splunk_entity)
      end

      context 'but does not need update' do
        let(:splunk_entity) { entity['config'] }
        it 'should not take any action' do
          expect(splunk_collection).to_not receive(:create).with(entity['name'], entity['config'])
          expect(splunk_entity).to_not receive(:update).with(entity['config'])

          subject.sync
        end
      end

      context 'and needs update' do
        let(:splunk_entity) { {} }

        before(:each) do
          allow(splunk_entity).to receive(:update)
        end

        it 'should update the entity' do
          expect(splunk_entity).to receive(:update).with(entity['config'])
          subject.sync
        end
      end
    end
  end

  context '#find' do

    let(:entity) { {'name' => 'entity-name'} }

    context 'successful request' do
      let(:splunk_entity) { double 'splunk_entity' }

      it 'should return the entity' do
        expect(Splunk::Entity).to receive(:new).with(service, service_namespace, ['resource'], entity['name']).and_return(splunk_entity)
        expect(subject.find(entity)).to eq(splunk_entity)
      end
    end

    context 'raises exception' do
      let(:response) { double 'response' }

      before(:each) do
        allow(response).to receive(:code).and_return(http_code)
        allow(response).to receive(:each).and_return([])
        allow(response).to receive(:body).and_return("")
        allow(response).to receive(:message).and_return("")

        allow(Splunk::Entity).to receive(:new).with(any_args).and_raise(error)
      end

      let(:error) { Splunk::SplunkHTTPError.new response }

      context 'with code 404' do
        let(:http_code) { 404 }
        it 'should return nil' do
          expect(subject.find(entity)).to eq(nil)
        end
      end

      context 'with code 500' do
        let(:http_code) { 500 }
        it 'should raise error' do
          expect { subject.find(entity) }.to raise_error(error)
        end
      end
    end
  end

  context '#skip?' do

    context 'entity has no envs' do
      let(:entity) { {} }
      it 'should return false' do
        expect(subject.skip?(entity)).to eq(false)
      end
    end

    context 'entity has envs' do
      context 'with environment included in envs' do
        let(:entity) { {'envs' => [environment]} }
        it 'should return false' do
          expect(subject.skip?(entity)).to eq(false)
        end
      end

      context 'with environment not included in envs' do
        let(:entity) { {'envs' => ['not-my-environment']} }
        it 'should return false' do
          expect(subject.skip?(entity)).to eq(true)
        end
      end
    end
  end

  context 'needs_update?' do
    let(:entity) { {'config' => {'key' => 'value'}} }

    context 'entity needs update' do
    let(:splunk_entity) { {} }
      it 'should return true' do
        expect(subject.needs_update?(splunk_entity, entity)).to eq(true)
      end
    end

    context 'entity does not need update' do
    let(:splunk_entity) { entity['config'] }
      it 'should return false' do
        expect(subject.needs_update?(splunk_entity, entity)).to eq(false)
      end
    end
  end

  context '#save' do
    let(:splunk_collection) { double 'splunk_collection' }
    let(:splunk_entity1) { double 'splunk_entity1' }
    let(:splunk_entity2) { double 'splunk_entity2' }
    let(:overwrite) { double 'overwrite' }

    before do
      entity_dir = File.join(execution_path, 'my-dir')
      allow(Dir).to receive(:exist?).with(entity_dir).and_return(true)
      allow(Splunk::Collection).to receive(:new).with(service, ['resource'])
                                                .and_return(splunk_collection)
      allow(splunk_collection).to receive(:map).and_yield(splunk_entity1)
                                               .and_yield(splunk_entity2)
    end

    it 'calls save_config on every object in the collection' do
      expect(subject).to receive(:save_config).with(splunk_entity1, false)
      expect(subject).to receive(:save_config).with(splunk_entity2, false)

      subject.save(false)
    end

    it 'passes the overwrite argument to every object in the collection' do
      expect(subject).to receive(:save_config).with(splunk_entity1, overwrite)
      expect(subject).to receive(:save_config).with(splunk_entity2, overwrite)

      subject.save(overwrite)
    end
  end

  context '#save_config' do
    let(:entity) { double 'entity' }
    let(:file_path) { double 'file_path' }
    let(:entity_config) do
      {
        'action.email' => true, 
        'action.email.sendresults' => true,
        'action.email.to' => 'email@email.com'
      }
    end
    let(:entity_name) { 'entity name' }

    before do
      allow(subject).to receive(:entity_file_path).and_return(file_path)
      allow(entity).to receive(:name).and_return(entity_name)
      allow(subject).to receive(:splunk_entity_keys).and_return(entity_config.keys)

      entity_config.map { |k, v| allow(entity).to receive(:fetch).with(k).and_return(v) }
    end

    context 'when the file exists' do
      before do
        allow(File).to receive(:exist?).and_return true
      end

      it 'does not write the config' do
        expect(File).to_not receive(:write)

        subject.save_config(entity, false)
      end

      context 'and overwrite is true' do
        it 'writes the config' do
          expect(File).to receive(:write)

          subject.save_config(entity, true)
        end
      end
    end

    context 'when the file does not exist' do
      before do
        allow(File).to receive(:exist?).and_return false
        allow(File).to receive(:write)
      end

      it 'gets all entity keys' do
        expect(subject).to receive(:splunk_entity_keys).and_return([])

        subject.save_config(entity, false)
      end

      it 'fetches every value for each entity key from the entity' do
        entity_config.each_key do |k|
          expect(entity).to receive(:fetch).with(k)
        end

        subject.save_config(entity, false)
      end

      it 'combines all entity key/values and writes to yaml' do
        expect(File).to receive(:write).with(file_path, {
          'name' => entity_name,
          'config' => entity_config
        }.to_yaml)

        subject.save_config(entity, false)
      end
    end
  end

  context '#entity_file_name' do
    context 'when the passed entity has only valid characters' do
      let(:entity) { double 'entity' }

      it 'returns entity.name with an extension' do
        allow(entity).to receive(:name).and_return('Entity0Name_-. ')

        expect(subject.entity_file_name(entity)).to eq('Entity0Name_-. .yml')
      end
    end

    context 'when the passed entity has invalid characters' do
      let(:entity) { double 'entity' }

      it 'returns entity.name without the invalid characters' do
        allow(entity).to receive(:name).and_return('EntityName/@! ')

        expect(subject.entity_file_name(entity)).to eq('EntityName .yml')
      end
    end
  end
end
