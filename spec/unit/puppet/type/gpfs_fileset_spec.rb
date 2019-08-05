require 'spec_helper'
require 'puppet/type/gpfs_fileset'

describe Puppet::Type.type(:gpfs_fileset) do
  before(:each) do
    @fileset = described_class.new(:name => 'test')
    @provider_class = described_class.provide(:rest_v2) do
      mk_resource_methods
      def create; end
      def delete; end
      def exists?; get(:ensure) != :absent; end
      def flush; end
      def self.instances; []; end
    end
  end

  it 'should add to catalog without raising an error' do
    catalog = Puppet::Resource::Catalog.new
    expect {
      catalog.add_resource @fileset 
    }.to_not raise_error
  end

  it 'should accept a fileset name' do
    expect(@fileset[:name]).to eq('test')
  end

  it 'should require a name' do
    expect {
      Puppet::Type.type(:gpfs_fileset).new({})
    }.to raise_error(Puppet::Error, 'Title or name must be provided')
  end

  it 'should accept a filesystem' do
    @fileset[:filesystem] = 'project'
    expect(@fileset[:filesystem]).to eq('project')
  end

  #it 'should not sync filesystem when fileset exists' do
  #  @provider = @provider_class.new(:name => 'foo', :ensure => :present)
  #  instance = described_class.new(:name => 'foo', :provider => @provider, :filesystem => 'test')
  #  expect(instance.property(:filesystem).insync?('test1')).to eq(true)
  #end

  #it 'should sync filesystem when fileset does not exist' do
  #  @provider = @provider_class.new(:name => 'foo', :ensure => :absent)
  #  instance = described_class.new(:name => 'foo', :provider => @provider, :filesystem => 'test')
  #  expect(instance.property(:filesystem).insync?(nil)).to eq(false)
  #end

  it 'should accept a path' do
    @fileset[:path] = '/fs/project/test'
    expect(@fileset[:path]).to eq('/fs/project/test')
  end

  it 'should not accept invalid path' do
    expect {
      @fileset[:path] = 'foobar'
    }.to raise_error(Puppet::ResourceError, /Fileset path must be fully qualified, not foobar/)
  end

  it 'should accept an owner' do
    @fileset[:owner] = 'root:root'
    expect(@fileset[:owner]).to eq('root:root')
  end
  it 'should not accept an owner with only user' do
    expect {
      @fileset[:owner] = 'root'
    }.to raise_error(Puppet::ResourceError)
  end

  it 'should accept permissions' do
    @fileset[:permissions] = '1770'
    expect(@fileset[:permissions]).to eq(1770)
    @fileset[:permissions] = '0770'
    expect(@fileset[:permissions]).to eq(770)
  end

  it 'should have inode_space default to new' do
    expect(@fileset[:inode_space]).to eq('new')
  end

  it 'should accept inode_space' do
    @fileset[:inode_space] = 'root'
    expect(@fileset[:inode_space]).to eq('root')
  end

  it 'should accept max_num_inodes' do
    @fileset[:max_num_inodes] = '1000000'
    expect(@fileset[:max_num_inodes]).to eq('1000000')
  end

  it 'should accept max_num_inodes as integer' do
    @fileset[:max_num_inodes] = 1000000
    expect(@fileset[:max_num_inodes]).to eq(1000000)
  end

  it 'should not accept non-numeric max_num_inodes' do
    expect {
      @fileset[:max_num_inodes] = 'foo'
    }.to raise_error(Puppet::ResourceError, /max_num_inodes foo is not a valid integer/)
  end

  it 'should accept alloc_inodes' do
    @fileset[:alloc_inodes] = '1000000'
    expect(@fileset[:alloc_inodes]).to eq('1000000')
  end

  it 'should accept alloc_inodes as integer' do
    @fileset[:alloc_inodes] = 1000000
    expect(@fileset[:alloc_inodes]).to eq(1000000)
  end

  it 'should not accept non-numeric alloc_inodes' do
    expect {
      @fileset[:alloc_inodes] = 'foo'
    }.to raise_error(Puppet::ResourceError, /alloc_inodes foo is not a valid integer/)
  end

  it 'should accept new_statefile' do
    @fileset[:new_statefile] = '.new_fileset'
    expect(@fileset[:new_statefile]).to eq('.new_fileset')
  end

  it 'should autorequire Service[gpfsgui]' do
    service = Puppet::Type.type(:service).new(:name => 'gpfsgui')
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource @fileset
    catalog.add_resource service
    rel = @fileset.autorequire[0]
    expect(rel.source.ref).to eq(service.ref)
    expect(rel.target.ref).to eq(@fileset.ref)
  end

end
