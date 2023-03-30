# frozen_string_literal: true

require 'spec_helper'
require 'puppet/type/gpfs_fileset_quota'

describe Puppet::Type.type(:gpfs_fileset_quota) do
  let(:quota) do
    described_class.new(name: 'test', filesystem: 'project')
  end

  it 'adds to catalog with raising an error' do
    catalog = Puppet::Resource::Catalog.new
    expect {
      catalog.add_resource quota
    }.not_to raise_error
  end

  it 'requires a name' do
    expect {
      Puppet::Type.type(:gpfs_fileset_quota).new({})
    }.to raise_error(Puppet::Error, 'Title or name must be provided')
  end

  it 'name should be set' do
    expect(quota[:name]).to eq('test')
  end

  it 'accepts a filesystem' do
    quota[:filesystem] = 'project'
    expect(quota[:filesystem]).to eq('project')
  end

  it 'has fileset default to name' do
    expect(quota[:fileset]).to eq('test')
  end

  it 'accepts a fileset' do
    quota[:fileset] = 'test1'
    expect(quota[:fileset]).to eq('test1')
  end

  it 'has object_name default to name' do
    expect(quota[:object_name]).to eq('test')
  end

  it 'defaults to type fileset' do
    expect(quota[:type]).to eq(:fileset)
  end

  it 'accepts non-default types' do
    quota[:type] = 'usr'
    expect(quota[:type]).to eq(:usr)
    quota[:type] = 'grp'
    expect(quota[:type]).to eq(:grp)
  end

  it 'downcases values' do
    quota[:type] = 'USR'
    expect(quota[:type]).to eq(:usr)
  end

  it 'does not accept invalid types' do
    expect {
      quota[:type] = 'foobar'
    }.to raise_error(Puppet::ResourceError, %r{Invalid type foobar. Valid values are usr, grp, fileset})
  end

  it 'accepts block_soft_limit 1T' do
    quota[:block_soft_limit] = '1T'
    expect(quota[:block_soft_limit]).to eq('1T')
  end

  it 'accepts block_soft_limit 1.8T' do
    quota[:block_soft_limit] = '1.8T'
    expect(quota[:block_soft_limit]).to eq('1.8T')
  end

  it 'accepts block_soft_limit 0' do
    quota[:block_soft_limit] = '0'
    expect(quota[:block_soft_limit]).to eq('0')
  end

  it 'does not allow integer block_soft_limit' do
    expect {
      quota[:block_soft_limit] = '1048576'
    }.to raise_error(Puppet::ResourceError, %r{Invalid block_soft_limit})
  end

  it 'accepts block_hard_limit 1T' do
    quota[:block_hard_limit] = '1T'
    expect(quota[:block_hard_limit]).to eq('1T')
  end

  it 'accepts block_hard_limit 1.8T' do
    quota[:block_hard_limit] = '1.8T'
    expect(quota[:block_hard_limit]).to eq('1.8T')
  end

  it 'accepts block_hard_limit 0' do
    quota[:block_hard_limit] = '0'
    expect(quota[:block_hard_limit]).to eq('0')
  end

  it 'does not allow integer block_hard_limit' do
    expect {
      quota[:block_hard_limit] = '1048576'
    }.to raise_error(Puppet::ResourceError, %r{Invalid block_hard_limit})
  end

  it 'accepts a files_soft_limit' do
    quota[:files_soft_limit] = '1000000'
    expect(quota[:files_soft_limit]).to eq(1_000_000)
  end

  it 'accepts a files_soft_limit as integer' do
    quota[:files_soft_limit] = 1_000_000
    expect(quota[:files_soft_limit]).to eq(1_000_000)
  end

  it 'converts files_soft_limit from 1M' do
    quota[:files_soft_limit] = '1M'
    expect(quota[:files_soft_limit]).to eq(1_000_000)
  end

  it 'converts files_soft_limit from 1K' do
    quota[:files_soft_limit] = '1K'
    expect(quota[:files_soft_limit]).to eq(1000)
  end

  it 'accepts a files_hard_limit' do
    quota[:files_hard_limit] = '1000000'
    expect(quota[:files_hard_limit]).to eq(1_000_000)
  end

  it 'accepts a files_hard_limit as integer' do
    quota[:files_hard_limit] = 1_000_000
    expect(quota[:files_hard_limit]).to eq(1_000_000)
  end

  it 'converts files_hard_limit from 1M' do
    quota[:files_hard_limit] = '1M'
    expect(quota[:files_hard_limit]).to eq(1_000_000)
  end

  it 'converts files_hard_limit from 1K' do
    quota[:files_hard_limit] = '1K'
    expect(quota[:files_hard_limit]).to eq(1000)
  end

  it 'autorequires gpfs_fileset' do
    fileset = Puppet::Type.type(:gpfs_fileset).new(name: 'test', filesystem: 'project')
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource quota
    catalog.add_resource fileset
    rel = quota.autorequire[0]
    expect(rel.source.ref).to eq(fileset.ref)
    expect(rel.target.ref).to eq(quota.ref)
  end

  it 'autorequires Service[gpfsgui]' do
    service = Puppet::Type.type(:service).new(name: 'gpfsgui')
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource quota
    catalog.add_resource service
    rel = quota.autorequire[0]
    expect(rel.source.ref).to eq(service.ref)
    expect(rel.target.ref).to eq(quota.ref)
  end
end
