Puppet::Type.newtype(:gpfs_fileset) do
  desc <<-DESC
@summary Manage a GPFS fileset

@example Create `test` GPFS fileset
  gpfs_fileset { 'test':
    filesystem      => 'project',
    path            => '/gpfs/project/test',
    owner           => 'nobody:wheel',
    permissions     => '1770',
    inode_space     => 'new',
    max_num_inodes  => 1000000,
    alloc_inodes    => 1000000,
  }

  DESC

  ensurable do
    desc 'The state of the fileset'

    defaultto(:present)
    newvalue(:present) do
      @resource.provider.create
    end
    newvalue(:absent) do
      @resource.provider.destroy
    end
    newvalue(:unlinked) do
      @resource.provider.unlink
      nil
    end

    def retreive
      if @resource.provider.exists? && @resource.provider.unlinked?
        :unlinked
      elsif @resource.provider.exists?
        :present
      else
        :absent
      end
    end
  end

  newparam(:name) do
    desc 'The default namevar.'
  end

  newparam(:fileset) do
    desc 'The GPFS fileset name.'

    defaultto do
      @resource[:name]
    end
  end

  newparam(:filesystem) do
    desc 'The GPFS filesystem name.'
  end

  newproperty(:path) do
    desc 'The GPFS fileset path.'

    validate do |value|
      unless Puppet::Util.absolute_path?(value)
        raise ArgumentError, 'Fileset path must be fully qualified, not %s' % value
      end
    end
  end

  newproperty(:owner) do
    desc 'Owner of GPFS fileset: user:group'

    validate do |value|
      unless value =~ %r{^\w+:\w+$}
        raise ArgumentError, 'Owner must be user:group, not %s' % value
      end
    end
  end

  newparam(:permissions) do
    desc 'Permissions of fileset.'

    munge do |value|
      value.to_i
    end
  end

  newparam(:inode_space) do
    desc 'inodeSpace of fileset.'
    defaultto('new')
  end

  newproperty(:max_num_inodes) do
    desc 'Max number of inodes for fileset.'

    validate do |value|
      unless value.to_s =~ %r{^\d+}
        raise ArgumentError, 'max_num_inodes %s is not a valid integer' % value
      end
    end

    def insync?(is)
      current = if is.is_a?(Array)
                  is[0].to_i
                else
                  is.to_i
                end
      should = if @should.is_a?(Array)
                 @should[0].to_i
               else
                 @should.to_i
               end
      # If the difference is less than or equal to inode_tolerance, consider in sync.
      diff = current - should
      if diff.abs <= @resource[:inode_tolerance]
        true
      else
        false
      end
    end
  end

  newproperty(:alloc_inodes) do
    desc 'Allocated inodes for fileset.'

    validate do |value|
      unless value.to_s =~ %r{^\d+$}
        raise ArgumentError, 'alloc_inodes %s is not a valid integer' % value
      end
    end

    def insync?(is)
      current = if is.is_a?(Array)
                  is[0].to_i
                else
                  is.to_i
                end
      should = if @should.is_a?(Array)
                 @should[0].to_i
               else
                 @should.to_i
               end
      # If more inodes are allocated than specified in Puppet, consider no change needed
      # as impossible to reduce allocated inodes
      if current > should
        return true
      end
      # If the difference is less than or equal to inode_tolerance, consider in sync.
      diff = current - should
      if diff.abs <= @resource[:inode_tolerance]
        true
      else
        false
      end
    end
  end

  newparam(:new_statefile) do
    desc 'Statefile that is created at root of a new fileset'
  end

  newparam(:inode_tolerance) do
    desc 'Number of inodes to allow GPFS to adjust max or allocated inodes without triggering a Puppet change'
    defaultto(32)
    validate do |value|
      if value && value.to_s != value.to_i.to_s
        raise ArgumentError, 'Expected an integer for inode_tolerance'
      end
    end
    munge do |value|
      value.to_i
    end
  end

  autorequire(:service) do
    ['gpfsgui']
  end

  autorequire(:scalemgmt_conn_validator) do
    ['gpfs']
  end

  validate do
    if self[:filesystem].nil?
      raise('Filesystem is required.')
    end
  end
end
