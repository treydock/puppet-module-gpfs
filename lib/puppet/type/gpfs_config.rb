# frozen_string_literal: true

Dir["#{File.dirname(__FILE__)}/gpfs*.rb"].sort.each do |file|
  require file unless file == __FILE__
end

Puppet::Type.newtype(:gpfs_config) do
  newparam(:name, namevar: true) do
    desc 'GPFS config'
  end

  newparam(:filesystems, array_matching: :all) do
    desc 'Filesystems to manage'
  end

  def generate
    [
      :gpfs_fileset,
      :gpfs_fileset_quota
    ].each do |res_type|
      provider_class = Puppet::Type.type(res_type).provider(:shell)
      provider_class.filesystems = self[:filesystems]
    end

    []
  end
end
