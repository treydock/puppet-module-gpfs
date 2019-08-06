Dir[File.dirname(__FILE__) + '/gpfs*.rb'].each do |file|
  require file unless file == __FILE__
end

Puppet::Type.newtype(:scalemgmt_config) do
  newparam(:name, namevar: true) do
    desc 'scalemgmt config'
  end

  newparam(:base_url) do
    defaultto('https://localhost:443/scalemgmt/')
  end

  newparam(:api_user) do
    defaultto('admin')
  end

  newparam(:api_password) do
    defaultto('admin001')
  end

  def generate
    [
      :gpfs_fileset,
      :gpfs_fileset_quota,
    ].each do |res_type|
      provider_class = Puppet::Type.type(res_type).provider(:rest_v2)
      provider_class.base_url = self[:base_url]
      provider_class.api_user = self[:api_user]
      provider_class.api_password = self[:api_password]
    end

    []
  end
end
