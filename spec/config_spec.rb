require 'spec_helper'

describe Splunk::Pickaxe::Config do

  let(:environment) { 'my-environment' }
  let(:url) { 'https://logs-api.dev.my-splunk.com' }
  let(:execution_path) { 'my-execution-path' }
  let(:my_app) { 'my-app' }
  let(:sharing) { 'app' }
  let(:yaml_config) { {'environments' => {'my-environment' => {'url' => url}}, 'namespace' => {sharing => my_app} } }
  let(:config) { Splunk::Pickaxe::Config.load(environment, execution_path) }

  before(:each) do
    config_path = File.join(execution_path, Splunk::Pickaxe::Config::CONFIG_FILE)
    expect(File).to receive(:exist?).with(config_path).and_return(true)
    expect(YAML).to receive(:load_file).with(config_path).and_return(yaml_config)
  end

  context '#load' do
    context 'using old config format' do
      let(:yaml_config) { {'environments' => {'my-environment' => url}, 'namespace' => {'app' => my_app} } }

      it 'should build config object' do
        expect(config.execution_path).to eq(File.join(execution_path))
        expect(config.emails).to eq([])
        expect(config.url).to eq(url)
        expect(config.environment).to eq(environment)
        expect(config.namespace).to eq(Splunk.namespace(:sharing => sharing, :app => my_app))
      end
    end

    it 'should build config object' do
      expect(config.execution_path).to eq(File.join(execution_path))
      expect(config.emails).to eq([])
      expect(config.url).to eq(url)
      expect(config.environment).to eq(environment)
      expect(config.namespace).to eq(Splunk.namespace(:sharing => sharing, :app => my_app))
    end

    context 'with environment emails specified' do
      let(:yaml_config) { {'environments' => {'my-environment' => {'url' => url, 'emails' => ['my@email.com']}},
        'namespace' => {sharing => my_app} } }

      it 'should use environment specific emails' do
        expect(config.emails).to eq(['my@email.com'])
      end
    end

    context 'with namespace included in the environment' do
      let(:yaml_config) { {'environments' => {'my-environment' => {'url' => url, 'emails' => ['my@email.com'], 'namespace' => {'app' => my_app} }}} }

      it 'should use environment specific namespace' do
        expect(config.namespace).to eq(Splunk.namespace(:sharing => sharing, :app => my_app))
      end

      context 'with no app in the namespace' do
        let(:yaml_config) { {'environments' => {'my-environment' => {'url' => url, 'emails' => ['my@email.com'], 'namespace' => {} }}} }

        it 'should raise an error' do
          expect { config }.to raise_error(StandardError)
        end
      end
    end

    context 'without environment emails specified and global emails set' do
      let(:yaml_config) { {'environments' => {'my-environment' => {'url' => url,}},
        'namespace' => {sharing => my_app}, 'emails' => ['my@email.com'] } }

      it 'should use environment specific emails' do
        expect(config.emails).to eq(['my@email.com'])
      end
    end

    context 'without namespace / app' do
      let(:yaml_config) { {'environments' => {'my-environment' => 'my-splunk'} } }
      it 'should raise an error' do
        expect { config }.to raise_error(StandardError)
      end
    end

    context 'without the environment' do
      let(:environment) { 'does-not-exist' }
      it 'should raise an error' do
        expect { config }.to raise_error(StandardError)
      end
    end
  end
end
