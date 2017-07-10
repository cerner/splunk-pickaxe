require 'spec_helper'

describe Splunk::Pickaxe::Config do

  let(:execution_path) { 'my-execution-path' }
  let(:yaml_config) { {'environments' => {'my-environment' => 'my-splunk'}, 'namespace' => {'app' => 'my-app'} } }
  let(:config) { Splunk::Pickaxe::Config.load(execution_path) }

  before(:each) do
    config_path = File.join(execution_path, Splunk::Pickaxe::Config::CONFIG_FILE)
    expect(File).to receive(:exist?).with(config_path).and_return(true)
    expect(YAML).to receive(:load_file).with(config_path).and_return(yaml_config)
  end

  context '#load' do
    it 'should build config object' do
      expect(config.execution_path).to eq(File.join(execution_path))
      expect(config.config).to eq({'namespace' => {'sharing' => 'app',
        'app' => 'my-app'}, 'environments' => {'my-environment' => 'my-splunk'},
        'emails' => []})
      expect(config.environments).to eq(yaml_config['environments'])
      expect(config.namespace).to eq(Splunk.namespace(:sharing => 'app', :app => 'my-app'))
    end

    context 'without namespace / app' do
      let(:yaml_config) { {'environments' => {'my-environment' => 'my-splunk'} } }
      it 'should raise an error' do
        expect { config }.to raise_error(StandardError)
      end
    end

    context 'with no environments' do
      let(:yaml_config) { {'namespace' => {'app' => 'my-app'}} }
      it 'should raise an error' do
        expect { config }.to raise_error(StandardError)
      end
    end
  end
end
