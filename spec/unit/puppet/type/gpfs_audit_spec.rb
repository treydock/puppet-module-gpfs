# frozen_string_literal: true

require 'spec_helper'
require 'puppet/type/gpfs_audit'

describe Puppet::Type.type(:gpfs_audit) do
  let(:audit) do
    described_class.new(name: 'test', filesystem: 'foo')
  end

  it 'adds to catalog without raising an error' do
    catalog = Puppet::Resource::Catalog.new
    expect {
      catalog.add_resource audit
    }.not_to raise_error
  end

  it 'accepts a audit name' do
    expect(audit[:name]).to eq('test')
  end

  it 'requires a name' do
    expect {
      Puppet::Type.type(:gpfs_audit).new({})
    }.to raise_error(Puppet::Error, 'Title or name must be provided')
  end

  it 'has filesystem default to name' do
    audit = Puppet::Type.type(:gpfs_audit).new({ name: 'test' })
    expect(audit[:filesystem]).to eq('test')
  end

  it 'accepts a filesystem' do
    audit[:filesystem] = 'project'
    expect(audit[:filesystem]).to eq('project')
  end

  it 'has default log_fileset' do
    expect(audit[:log_fileset]).to eq('.audit_log')
  end

  it 'accepts a log_fileset' do
    audit[:log_fileset] = 'test'
    expect(audit[:log_fileset]).to eq('test')
  end

  it 'has default retention' do
    expect(audit[:retention]).to eq(365)
  end

  it 'accepts a retention' do
    audit[:retention] = 5
    expect(audit[:retention]).to eq(5)
  end

  it 'does not accept invalid retention' do
    expect {
      audit[:retention] = 'foobar'
    }.to raise_error(Puppet::ResourceError, %r{Expected an integer for retention})
  end

  it 'has default events' do
    expect(audit[:events]).to eq(['ALL'])
  end

  it 'accepts events' do
    audit[:events] = ['CREATE', 'OPEN']
    expect(audit[:events]).to eq(['CREATE', 'OPEN'])
  end

  it 'has default compliant' do
    expect(audit[:compliant]).to eq(:false)
  end

  it 'allows compliant' do
    audit[:compliant] = true
    expect(audit[:compliant]).to eq(:true)
  end

  it 'does not accept invalid compliant' do
    expect {
      audit[:compliant] = 'foobar'
    }.to raise_error(Puppet::ResourceError)
  end

  it 'allows filesets' do
    audit[:filesets] = ['test1', 'test2']
    expect(audit[:filesets]).to eq(['test1', 'test2'])
  end

  it 'allows skip_filesets' do
    audit[:skip_filesets] = ['test1', 'test2']
    expect(audit[:skip_filesets]).to eq(['test1', 'test2'])
  end

  it 'has default disable_missing' do
    expect(audit[:disable_missing]).to eq(:false)
  end

  it 'allows disable_missing' do
    audit[:disable_missing] = true
    expect(audit[:disable_missing]).to eq(:true)
  end

  it 'does not allow filesets and skip_filesets' do
    audit[:filesets] = ['foo']
    audit[:skip_filesets] = ['bar']
    expect {
      audit.validate
    }.to raise_error(%r{filesets and skip_filesets are mutually exclusive})
  end

  it 'autorequires gpfs_fileset' do
    audit[:filesets] = ['fileset1']
    fileset1 = Puppet::Type.type(:gpfs_fileset).new(name: 'fileset1', filesystem: 'foo')
    fileset2 = Puppet::Type.type(:gpfs_fileset).new(name: 'fileset2', filesystem: 'foo')
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource audit
    catalog.add_resource fileset1
    catalog.add_resource fileset2
    expect(audit.autorequire.size).to eq(1)
    rel = audit.autorequire[0]
    expect(rel.source.ref).to eq(fileset1.ref)
    expect(rel.target.ref).to eq(audit.ref)
  end
end
