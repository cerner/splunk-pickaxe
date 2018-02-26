require 'spec_helper'

describe Splunk::Pickaxe::Dashboards do
  let(:service) { double 'service' }
  let(:environment) { 'my-environment' }
  let(:pickaxe_config) { double 'pickaxe_config' }
  let(:service_namespace) { double 'service_namespace' }
  let(:execution_path) { 'execution_path' }
  let(:subject) { Splunk::Pickaxe::Dashboards.new service, environment, pickaxe_config }
  let(:entity) { double 'entity' }
  let(:env_config) { { 'content' => 'content' } }

  before do
    allow(service).to receive(:namespace).and_return(service_namespace)
    allow(pickaxe_config).to receive(:execution_path).and_return(execution_path)
    allow(pickaxe_config).to receive(:env_config).and_return(env_config)
    allow(subject).to receive(:puts).with(any_args)
  end

  context '#entity_file_name' do
    context 'when the passed entity has only valid characters' do
      it 'returns entity[\'label\'] with an extension' do
        allow(entity).to receive(:[]).with('label').and_return('Entity0Name_-.')

        expect(subject.entity_file_name(entity)).to eq('Entity0Name_-..xml')
      end
    end

    context 'when the passed entity has spaces' do
      it 'replaces them with underscores' do
        allow(entity).to receive(:[]).with('label').and_return('Entity Name   ')

        expect(subject.entity_file_name(entity)).to eq('Entity_Name___.xml')
      end
    end

    context 'when the passed entity has invalid characters' do
      it 'returns entity[\'label\'] without the invalid characters' do
        allow(entity).to receive(:[]).with('label').and_return('EntityName/@!')

        expect(subject.entity_file_name(entity)).to eq('EntityName.xml')
      end
    end
  end

  context '#config' do
    let(:file_path) { double 'file_path' }
    let(:basename) { 'basename' }
    let(:file_contents) { %{file <%= content %>} }
    let(:interpolated_file_contents) { 'file content' }

    before do
      allow(File).to receive(:basename).and_return(basename)
      allow(IO).to receive(:read).and_return(file_contents)
    end

    it 'reads from file_path' do
      expect(IO).to receive(:read).with(file_path)

      subject.config(file_path)
    end

    it 'returns a hash with name equal to the file name' do
      expect(subject.config(file_path).values_at('name')).to include(basename)
    end

    it 'returns a hash with config read from file_path' do
      expect(subject.config(file_path).values_at('config')).to include(
        'eai:data' => interpolated_file_contents
      )
    end
  end

  context '#save_config' do
    let(:entity) { double 'entity' }
    let(:file_path) { double 'file_path' }
    let(:entity_config) do
      <<-XML
      <?xml version="1.0"?>
        <view template="pages/app.html" type="html" isDashboard="False">
        <label>Alerts</label>
      </view>
      XML
    end

    before do
      allow(subject).to receive(:entity_file_path).and_return(file_path)
      allow(entity).to receive(:[]).with('label').and_return('entity name')
      allow(entity).to receive(:[]).with('eai:data').and_return(entity_config)
      allow(File).to receive(:exist?).and_return true
    end

    context 'when the file exists' do
      it 'does not write the config' do
        allow(File).to receive(:exist?).and_return true
        expect(File).to_not receive(:write)

        subject.save_config(entity, false)
      end

      context 'and overwrite is passed' do
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

      it 'gets eai:data from the entity' do
        expect(entity).to receive(:[]).with('eai:data').and_return({})

        subject.save_config(entity, false)
      end

      it 'writes eai:data to the file' do
        expect(File).to receive(:write).with(file_path, entity_config)

        subject.save_config(entity, false)
      end
    end
  end
end
