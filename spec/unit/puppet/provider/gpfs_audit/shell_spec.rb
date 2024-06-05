# frozen_string_literal: true

require 'spec_helper'

describe Puppet::Type.type(:gpfs_audit).provider(:shell) do
  let(:type) do
    Puppet::Type.type(:gpfs_audit)
  end
  let(:resource) do
    type.new(name: 'test', provider: 'shell')
  end

  let(:mmaudits) do
    [
      { ensure: :present, name: 'ess', filesystem: 'ess', compliant: :true,
        log_fileset: '.audit_log', retention: 365, events: ['ALL'] },
      { ensure: :present, name: 'scratch', filesystem: 'scratch', compliant: :false,
        log_fileset: 'audit', retention: 25,
        events: ['ALL'], filesets: ['fastest1', 'fastest2'] },
      { ensure: :present, name: 'test', filesystem: 'test', compliant: :false,
        log_fileset: 'audit', retention: 25,
        events: ['ACCESS_DENIED', 'ACLCHANGE', 'CLOSE', 'CREATE', 'GPFSATTRCHANGE', 'OPEN'],
        skip_filesets: ['faltest2'] }
    ]
  end

  describe 'self.instances' do
    it 'creates instances' do
      allow(described_class).to receive(:mmaudit).with('all', 'list', '-Y').and_return(my_fixture_read('mmaudit.out'))
      expect(described_class.instances.length).to eq(3)
      expect(described_class.instances[0].instance_variable_get('@property_hash')).to eq(mmaudits[0])
      expect(described_class.instances[1].instance_variable_get('@property_hash')).to eq(mmaudits[1])
      expect(described_class.instances[2].instance_variable_get('@property_hash')).to eq(mmaudits[2])
    end

    it 'creates no instance when no mmaudits returned' do
      allow(described_class).to receive(:mmaudit).with('all', 'list', '-Y').and_return(my_fixture_read('mmaudit.out').split("\n")[0])
      expect(described_class.instances.length).to be_zero
    end
  end

  describe 'self.prefetch' do
    let(:instances) do
      mmaudits.map { |f| described_class.new(f) }
    end
    let(:resources) do
      mmaudits.each_with_object({}) do |f, h|
        h[f[:name]] = type.new(f.reject { |_k, v| v.nil? })
      end
    end

    before(:each) do
      allow(described_class).to receive(:instances).and_return(instances)
    end

    it 'prefetches' do
      resources.each_key do |r|
        expect(resources[r]).to receive(:provider=).with(described_class)
      end
      described_class.prefetch(resources)
    end
  end

  describe 'create' do
    it 'enables mmaudit' do
      expected = [
        'test', 'enable',
        '--log-fileset', '.audit_log',
        '--retention', '365',
        '--events', 'ALL'
      ]
      expect(resource.provider).to receive(:mmaudit).with(expected)
      resource.provider.create
      property_hash = resource.provider.instance_variable_get('@property_hash')
      expect(property_hash[:ensure]).to eq(:present)
    end
  end

  describe 'destroy' do
    it 'disables mmaudit' do
      expect(resource.provider).to receive(:mmaudit).with(['test', 'disable'])
      resource.provider.destroy
      property_hash = resource.provider.instance_variable_get('@property_hash')
      expect(property_hash).to eq({})
    end
  end

  describe 'flush' do
    it 'modifies mmaudit' do
      expect(resource.provider).to receive(:mmaudit).with(['test', 'update', '--events', 'foo,bar'])
      resource.provider.events = ['foo', 'bar']
      resource.provider.flush
    end

    it 'adds filesets' do
      hash = resource.to_hash
      hash[:filesets] = ['foo']
      resource.provider.instance_variable_set(:@property_hash, hash)
      expect(resource.provider).to receive(:mmaudit).with(['test', 'update', '--enable-filesets', 'bar,baz'])
      resource.provider.filesets = ['foo', 'bar', 'baz']
      resource.provider.flush
    end

    it 'does not remove filesets' do
      hash = resource.to_hash
      hash[:filesets] = ['foo', 'bar', 'baz']
      resource.provider.instance_variable_set(:@property_hash, hash)
      expect(resource.provider).not_to receive(:mmaudit).with(['test', 'update', '--disable-filesets', 'baz'])
      resource.provider.filesets = ['foo', 'bar']
      resource.provider.flush
    end

    it 'remove filesets when disable_missing' do
      resource[:disable_missing] = true
      hash = resource.to_hash
      hash[:filesets] = ['foo', 'bar', 'baz']
      resource.provider.instance_variable_set(:@property_hash, hash)
      expect(resource.provider).to receive(:mmaudit).with(['test', 'update', '--disable-filesets', 'baz'])
      resource.provider.filesets = ['foo', 'bar']
      resource.provider.flush
    end
  end
end
