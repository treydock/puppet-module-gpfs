Dir[File.dirname(__FILE__) + '/gpfs*.rb'].each do |file|
  require file unless file == __FILE__
end

Puppet::Type.newtype(:gpfs_config) do
  newparam(:name, namevar: true) do
    desc 'GPFS config'
  end

  newparam(:filesystems, array_matching: :all) do
    desc 'Filesystems to manage'
  end

  newparam(:inode_tolerance) do
    desc 'Number of inodes to allow GPFS to adjust max or allocated inodes without triggering a Puppet change'
    defaultto('32')
    validate do |value|
      if value && value.to_s != value.to_i.to_s
        raise ArgumentError, 'Expected an integer for inode_tolerance'
      end
    end
    munge do |value|
      value.to_i
    end
  end

  def generate
    [
      :gpfs_fileset,
      :gpfs_fileset_quota,
    ].each do |res_type|
      provider_class = Puppet::Type.type(res_type).provider(:shell)
      provider_class.filesystems = self[:filesystems]
      provider_class.inode_tolerance = self[:inode_tolerance]
    end

    []
  end
end
