require File.expand_path(File.join(File.dirname(__FILE__), '..', 'gpfs'))
require 'etc'
require 'uri'

Puppet::Type.type(:gpfs_fileset).provide(:shell, parent: Puppet::Provider::Gpfs) do
  desc ''

  mk_resource_methods

  defaultfor osfamily: :redhat

  commands chown: 'chown'
  commands chmod: 'chmod'
  commands mmlsfileset: '/usr/lpp/mmfs/bin/mmlsfileset'
  # commands :mmclidecode => '/usr/lpp/mmfs/bin/mmclidecode'
  commands mmcrfileset: '/usr/lpp/mmfs/bin/mmcrfileset'
  commands mmlinkfileset: '/usr/lpp/mmfs/bin/mmlinkfileset'
  commands mmunlinkfileset: '/usr/lpp/mmfs/bin/mmunlinkfileset'
  commands mmdelfileset: '/usr/lpp/mmfs/bin/mmdelfileset'
  commands mmchfileset: '/usr/lpp/mmfs/bin/mmchfileset'

  def self.instances
    filesets = []
    mmlsfs_filesystems.each do |filesystem|
      mmlsfileset_output = mmlsfileset(filesystem, '-Y')
      mmlsfileset_output.each_line do |line|
        fileset = {}
        l = line.strip.split(':')
        next if l[2] == 'HEADER'
        fileset[:ensure] = :present
        fileset[:filesystem] = l[6]
        fileset[:fileset] = l[7]
        fileset[:name] = "#{fileset[:filesystem]}/#{fileset[:fileset]}"
        fileset[:path] = URI.unescape(l[11]) unless l[11].nil?
        fileset[:max_num_inodes] = l[32].to_i
        fileset[:alloc_inodes] = l[33].to_i
        fileset[:owner] = nil
        if !fileset[:path].nil? && File.directory?(fileset[:path])
          # Get owner
          s = File.stat(fileset[:path])
          user = Etc.getpwuid(s.uid).name
          group = Etc.getgrgid(s.gid).name
          fileset[:owner] = "#{user}:#{group}"
        end
        filesets << new(fileset)
      end
    end
    filesets
  end

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

  def default_path(filesystem, fileset)
    mountpoint = nil
    mmlsfs_out = mmlsfs(filesystem, '-T', '-Y')
    mmlsfs_out.each_line do |line|
      l = line.strip.split(':')
      next if l[2] == 'HEADER'
      mountpoint = URI.unescape(l[8])
    end
    raise("Unable to determine filesystem mount point for filesystem #{filesystem}") if mountpoint.nil?
    path = File.join(mountpoint, fileset)
    path
  end

  def create
    raise("Filesystem is mandatory for #{resource.type} #{resource.name}") if resource[:filesystem].nil?

    mmcrfileset_args = [resource[:filesystem], resource[:fileset]]
    if resource[:inode_space]
      mmcrfileset_args << '--inode-space'
      mmcrfileset_args << resource[:inode_space]
    end
    if resource[:max_num_inodes] && resource[:alloc_inodes]
      mmcrfileset_args << '--inode-limit'
      mmcrfileset_args << "#{resource[:max_num_inodes]}:#{resource[:alloc_inodes]}"
    elsif resource[:max_num_inodes]
      mmcrfileset_args << '--inode-limit'
      mmcrfileset_args << resource[:max_num_inodes]
    end

    path = if resource[:path]
             resource[:path]
           else
             default_path(resource[:filesystem], resource[:fileset])
           end

    mmlinkfileset_args = [resource[:filesystem], resource[:fileset]]
    mmlinkfileset_args << '-J'
    mmlinkfileset_args << path

    mmcrfileset(mmcrfileset_args)
    mmlinkfileset(mmlinkfileset_args)

    if resource[:new_statefile]
      new_statefile_path = File.join(path, resource[:new_statefile])
      require 'fileutils'
      FileUtils.touch(new_statefile_path)
      chmod('0400', new_statefile_path)
    end

    chmod(resource[:permissions], path) if resource[:permissions]
    chown(resource[:owner], path) if resource[:owner]

    @property_hash[:ensure] = :present
  end

  def destroy
    raise("Filesystem is mandatory for #{resource.type} #{resource.name}") if resource[:filesystem].nil?

    mmunlinkfileset([resource[:filesystem], resource[:fileset]])
    mmdelfileset([resource[:filesystem], resource[:fileset]])

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

    if @property_flush[:permissions] || @property_flush[:owner]
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
          Puppet.warning("Unable to set owner for #{resource.type} #{resource.name}, path #{path} does not exist")
        end
      end
    end

    # Sanity check max_num_inodes is not lower than allocated inodes
    if @property_flush[:max_num_inodes]
      if @property_hash[:alloc_inodes].to_i > @property_flush[:max_num_inodes].to_i
        Puppet.warning("Fileset #{resource[:name]}: Decreasing max inodes (#{@property_flush[:max_num_inodes]}) to be less than allocated inodes (#{@property_hash[:alloc_inodes]}) is not permitted")
        @property_flush.delete(:max_num_inodes)
      end
    end
    # Sanity check alloc_inodes is not lower than previous value
    if @property_flush[:alloc_inodes]
      if @property_hash[:alloc_inodes].to_i > @property_flush[:alloc_inodes].to_i
        Puppet.warning("Fileset #{resource[:name]}: decreasing allocated inodes from #{@property_hash[:alloc_inodes]} to #{@property_flush[:alloc_inodes]} is not permitted")
        @property_flush.delete(:alloc_inodes)
      end
    end

    if @property_flush[:max_num_inodes] || @property_flush[:alloc_inodes]
      mmchfileset_args = [resource[:filesystem], resource[:fileset]]
      if @property_flush[:max_num_inodes] && @property_flush[:alloc_inodes]
        mmchfileset_args << '--inode-limit'
        mmchfileset_args << "#{@property_flush[:max_num_inodes]}:#{@property_flush[:alloc_inodes]}"
      elsif @property_flush[:max_num_inodes]
        mmchfileset_args << '--inode-limit'
        mmchfileset_args << @property_flush[:max_num_inodes]
      elsif @property_flush[:alloc_inodes]
        mmchfileset_args << '--inode-limit'
        mmchfileset_args << "#{@property_hash[:max_num_inodes]}:#{@property_flush[:alloc_inodes]}"
      end

      mmchfileset(mmchfileset_args)
    end

    # Collect the resources again once they've been changed (that way `puppet
    # resource` will show the correct values after changes have been made).
    @property_hash = resource.to_hash
  end
end
