# frozen_string_literal: true

require 'spec_helper'
require 'puppet/type/gpfs_fileset'

describe Puppet::Type.type(:gpfs_fileset) do
  let(:fileset) do
    described_class.new(name: 'test', filesystem: 'foo')
  end
  let(:provider_class) do
    described_class.provide(:rest_v2) do
      mk_resource_methods
      def create; end

      def delete; end

      def exists?
        get(:ensure) != :absent
      end

      def flush; end

      def self.instances
        []
      end
    end
  end

  it 'adds to catalog without raising an error' do
    catalog = Puppet::Resource::Catalog.new
    expect {
      catalog.add_resource fileset
    }.not_to raise_error
  end

  it 'accepts a fileset name' do
    expect(fileset[:name]).to eq('test')
  end

  it 'requires a name' do
    expect {
      Puppet::Type.type(:gpfs_fileset).new({})
    }.to raise_error(Puppet::Error, 'Title or name must be provided')
  end

  it 'accepts a filesystem' do
    fileset[:filesystem] = 'project'
    expect(fileset[:filesystem]).to eq('project')
  end

  # it 'should not sync filesystem when fileset exists' do
  #  @provider = @provider_class.new(:name => 'foo', :ensure => :present)
  #  instance = described_class.new(:name => 'foo', :provider => @provider, :filesystem => 'test')
  #  expect(instance.property(:filesystem).insync?('test1')).to eq(true)
  # end

  # it 'should sync filesystem when fileset does not exist' do
  #  @provider = @provider_class.new(:name => 'foo', :ensure => :absent)
  #  instance = described_class.new(:name => 'foo', :provider => @provider, :filesystem => 'test')
  #  expect(instance.property(:filesystem).insync?(nil)).to eq(false)
  # end

  it 'accepts a path' do
    fileset[:path] = '/fs/project/test'
    expect(fileset[:path]).to eq('/fs/project/test')
  end

  it 'does not accept invalid path' do
    expect {
      fileset[:path] = 'foobar'
    }.to raise_error(Puppet::ResourceError, %r{Fileset path must be fully qualified, not foobar})
  end

  it 'accepts an owner' do
    fileset[:owner] = 'root:root'
    expect(fileset[:owner]).to eq('root:root')
  end

  it 'does not accept an owner with only user' do
    expect {
      fileset[:owner] = 'root'
    }.to raise_error(Puppet::ResourceError)
  end

  it 'accepts permissions' do
    fileset[:permissions] = '1770'
    expect(fileset[:permissions]).to eq('1770')
    fileset[:permissions] = '0770'
    expect(fileset[:permissions]).to eq('0770')
  end

  it 'does not accept invalid permissions of 3 digits' do
    expect {
      fileset[:permissions] = '700'
    }.to raise_error(Puppet::ResourceError)
  end

  it 'does not accept invalid permissions' do
    expect {
      fileset[:permissions] = 'foo'
    }.to raise_error(Puppet::ResourceError)
  end

  it 'has inode_space default to new' do
    expect(fileset[:inode_space]).to eq('new')
  end

  it 'accepts inode_space' do
    fileset[:inode_space] = 'root'
    expect(fileset[:inode_space]).to eq('root')
  end

  it 'accepts max_num_inodes' do
    fileset[:max_num_inodes] = '1000000'
    expect(fileset[:max_num_inodes]).to eq('1000000')
  end

  it 'accepts max_num_inodes as integer' do
    fileset[:max_num_inodes] = 1_000_000
    expect(fileset[:max_num_inodes]).to eq(1_000_000)
  end

  describe 'max_num_inodes insync?' do
    it 'is insync with default tolerance' do
      fileset[:max_num_inodes] = 1_000_000
      expect(fileset.property(:max_num_inodes).insync?(1_000_032)).to eq(true)
    end

    it 'is not insync with no tolerance' do
      fileset[:max_num_inodes] = 1_000_000
      expect(fileset.property(:max_num_inodes).insync?(1_002_048)).to eq(false)
    end

    it 'is insync with tolerance' do
      fileset[:max_num_inodes] = 1_000_000
      fileset[:inode_tolerance] = 2048
      expect(fileset.property(:max_num_inodes).insync?(1_002_048)).to eq(true)
    end
  end

  it 'does not accept non-numeric max_num_inodes' do
    expect {
      fileset[:max_num_inodes] = 'foo'
    }.to raise_error(Puppet::ResourceError, %r{max_num_inodes foo is not a valid integer})
  end

  it 'accepts alloc_inodes' do
    fileset[:alloc_inodes] = '1000000'
    expect(fileset[:alloc_inodes]).to eq('1000000')
  end

  it 'accepts alloc_inodes as integer' do
    fileset[:alloc_inodes] = 1_000_000
    expect(fileset[:alloc_inodes]).to eq(1_000_000)
  end

  it 'does not accept non-numeric alloc_inodes' do
    expect {
      fileset[:alloc_inodes] = 'foo'
    }.to raise_error(Puppet::ResourceError, %r{alloc_inodes foo is not a valid integer})
  end

  it 'accepts inode_tolerance as String' do
    fileset[:inode_tolerance] = '1024'
    expect(fileset[:inode_tolerance]).to eq(1024)
  end

  it 'accepts inode_tolerance as Integer' do
    fileset[:inode_tolerance] = 2048
    expect(fileset[:inode_tolerance]).to eq(2048)
  end

  it 'does not accept inode_tolerance not number' do
    expect { fileset[:inode_tolerance] = 'foo' }.to raise_error(Puppet::ResourceError, %r{Expected an integer for inode_tolerance})
  end

  it 'does not accept inode_tolerance as Float' do
    expect { fileset[:inode_tolerance] = 1.5 }.to raise_error(Puppet::ResourceError, %r{Expected an integer for inode_tolerance})
  end

  it 'does not accept non-Hash afm_attributes' do
    expect {
      fileset[:afm_attributes] = 'foo'
    }.to raise_error(Puppet::ResourceError, %r{got String})
  end

  it 'accepts Hash for afm_attributes' do
    fileset[:afm_attributes] = { 'afmTarget' => 'foo', 'afmMode' => 'read-only' }
    expect(fileset[:afm_attributes]).to eq('afmTarget' => 'foo', 'afmMode' => 'read-only')
  end

  it 'autorequires Service[gpfsgui]' do
    service = Puppet::Type.type(:service).new(name: 'gpfsgui')
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource fileset
    catalog.add_resource service
    rel = fileset.autorequire[0]
    expect(rel.source.ref).to eq(service.ref)
    expect(rel.target.ref).to eq(fileset.ref)
  end
end
