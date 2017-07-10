require 'spec_helper'

describe Splunk::Pickaxe::Client do

  splunk_object_classes.each do |clazz|
    let(clazz.to_s.to_sym){ double(clazz.to_s) }
  end

  let(:service) { double 'service' }
  let(:environment){ 'my-environment' }
  let(:config) { double 'config' }
  let(:client) { Splunk::Pickaxe::Client.new(service, environment, config) }

  before(:each) do
    splunk_object_classes.each do |clazz|
      allow(clazz).to receive(:new).with(any_args).and_return(eval(clazz.to_s))
    end
  end

  context '#sync_all' do

    it 'should sync all objects' do
      splunk_object_classes.each do |clazz|
        expect(eval(clazz.to_s)).to receive(:sync)
      end

      client.sync_all
    end
  end
end
