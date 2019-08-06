require File.expand_path(File.join(File.dirname(__FILE__), '..', 'gpfs'))
require 'fileutils'
require 'etc'

Puppet::Type.type(:gpfs_fileset).provide(:rest_v2, parent: Puppet::Provider::Gpfs) do
  desc ''

  mk_resource_methods
  set_scalemgmt_defaults

  confine osfamily: :false

  commands chown: 'chown'

  def self.instances
    filesets = []
    params = {
      'fields' => ':all:',
    }
    data = get_request('v2/filesystems/:all:/filesets', params)
    unless data.key?('filesets')
      return filesets
    end

    data['filesets'].map do |fileset|
      filesystem = fileset['config']['filesystemName']
      name = fileset['config']['filesetName']
      path = fileset['config']['path']
      max_num_inodes = fileset['config']['maxNumInodes']
      owner = nil
      if File.directory?(path)
        # Get owner
        s = File.stat(path)
        user = Etc.getpwuid(s.uid).name
        group = Etc.getgrgid(s.gid).name
        owner = "#{user}:#{group}"
      end

      new(
        ensure: :present,
        name: "#{filesystem}/#{name}",
        fileset: name,
        filesystem: filesystem,
        path: path,
        max_num_inodes: max_num_inodes,
        owner: owner,
      )
    end
  end

  # def self.instances
  #  get_filesets.each do |fileset|
  #    new(fileset)
  #  end
  # end

  def self.prefetch(resources)
    filesets = instances
    resources.keys.each do |name|
      provider = filesets.find do |fileset|
        fileset.fileset == resources[name][:fileset] && fileset.filesystem == resources[name][:filesystem]
      end
      next unless provider
      resources[name].provider = provider
    end
  end

  def create
    raise("Filesystem is mandatory for #{resource.type} #{resource.name}") if resource[:filesystem].nil?

    data = {}
    data[:filesetName] = resource[:fileset]
    data[:path] = resource[:path] if resource[:path]
    data[:owner] = resource[:owner] if resource[:owner]
    data[:permissions] = resource[:permissions] if resource[:permissions]
    data[:inodeSpace] = resource[:inode_space] if resource[:inode_space]
    data[:maxNumInodes] = resource[:max_num_inodes] if resource[:max_num_inodes]
    data[:allocInodes] = resource[:alloc_inodes] if resource[:alloc_inodes]
    uri_path = "v2/filesystems/#{resource[:filesystem]}/filesets"

    begin
      post_request(uri_path, data)
    rescue Exception => e # rubocop:disable Lint/RescueException
      raise Puppet::Error, "POST to #{uri_path} failed\nError message: #{e.message}"
    end

    @property_hash[:ensure] = :present
  end

  def destroy
    raise("Filesystem is mandatory for #{resource.type} #{resource.name}") if resource[:filesystem].nil?

    uri_path = "v2/filesystems/#{resource[:filesystem]}/filesets/#{resource[:fileset]}"
    begin
      delete_request(uri_path)
    rescue Exception => e # rubocop:disable Lint/RescueException
      raise Puppet::Error, "DELETE to #{uri_path} failed\nError message: #{e.message}"
    end

    @property_hash.clear
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def initialize(value = {})
    super(value)
    @property_flush = {}
  end

  def path=(value)
    # How to change path?
  end

  def owner=(value)
    @property_flush[:owner] = value
  end

  def max_num_inodes=(value)
    @property_flush[:max_num_inodes] = value
  end

  def alloc_inodes=(value)
    @property_flush[:alloc_inodes] = value
  end

  def flush
    raise("Filesystem is mandatory for #{resource.type} #{resource.name}") if resource[:filesystem].nil?

    if @property_flush[:owner]
      # Determine path
      if resource[:path]
        path = resource[:path]
      elsif @property_hash[:path]
        path = @property_hash[:path]
      else
        path = ''
        Puppet.warning("Unable to determine path for #{resource.type} #{resource.name}")
      end
      # Set owner
      if @property_flush[:owner]
        if File.directory?(path)
          chown(@property_flush[:owner], path)
        else
          Puppet.warning("Unable to set permissions for #{resource.type} #{resource.name}, path #{path} does not exist")
        end
      end
    end

    if @property_flush[:max_num_inodes] || @property_flush[:alloc_inodes]
      # Sanity check max_num_inodes is not lower than previous value
      if @property_flush[:max_num_inodes]
        if @property_hash[:max_num_inodes].to_i > @property_flush[:max_num_inodes].to_i
          Puppet.warning("Fileset #{resource[:name]}: decreasing max inodes from #{@property_hash[:max_num_inodes]} to #{@property_flush[:max_num_inodes]} is not permitted")
          @property_flush.delete(:max_num_inodes)
        end
      end
      # Sanity check alloc_inodes is not lower than previous value
      # WARNING: API does not currently support querying allocated inodes
      if @property_flush[:alloc_inodes]
        if @property_hash[:alloc_inodes].to_i > @property_flush[:alloc_inodes].to_i
          Puppet.warning("Fileset #{resource[:name]}: decreasing allocated inodes from #{@property_hash[:alloc_inodes]} to #{@property_flush[:alloc_inodes]} is not permitted")
          @property_flush.delete(:alloc_inodes)
        end
      end

      data = {}
      data[:maxNumInodes] = @property_flush[:max_num_inodes] if @property_flush[:max_num_inodes]
      data[:allocInodes] = @property_flush[:alloc_inodes] if @property_flush[:alloc_inodes]

      uri_path = "v2/filesystems/#{resource[:filesystem]}/filesets/#{resource[:fileset]}"

      begin
        put_request(uri_path, data)
      rescue Exception => e # rubocop:disable Lint/RescueException
        raise Puppet::Error, "PUT to #{uri_path} failed\nError message: #{e.message}"
      end
    end
    # Collect the resources again once they've been changed (that way `puppet
    # resource` will show the correct values after changes have been made).
    @property_hash = resource.to_hash
  end
end
