require File.expand_path(File.join(File.dirname(__FILE__), '..', 'gpfs'))

Puppet::Type.type(:gpfs_fileset_quota).provide(:rest_v2, parent: Puppet::Provider::Gpfs) do
  desc ''

  mk_resource_methods
  set_scalemgmt_defaults

  confine osfamily: :false

  def self.instances
    quotas = []
    params = {
      'entityType' => 'FILESET',
      'fields' => ':all:',
    }
    data = get_request('v2/filesystems/:all:/quotas', params)
    unless data.key?('quotas')
      return quotas
    end

    data['quotas'].map do |q|
      quota = {
        ensure: :present,
      }
      quota[:filesystem] = q['filesystemName']
      quota[:fileset] = q['objectName']
      quota[:type] = q['quotaType'].downcase
      quota[:object_name] = q['objectName']
      quota[:name] = "#{quota[:filesystem]}/#{quota[:fileset]}/#{quota[:object_name]}"
      # block limits are returned in KB but numeric inputs are treated as bytes
      quota[:block_soft_limit] = human_readable_kilobytes(q['blockQuota']) if q['blockQuota']
      quota[:block_hard_limit] = human_readable_kilobytes(q['blockLimit']) if q['blockLimit']
      quota[:files_soft_limit] = q['filesQuota'] if q['filesQuota']
      quota[:files_hard_limit] = q['filesLimit'] if q['filesLimit']
      new(quota)
    end
  end

  def self.prefetch(resources)
    quotas = instances
    resources.keys.each do |name|
      provider = quotas.find do |quota|
        quota.fileset == resources[name][:fileset] &&
          quota.filesystem == resources[name][:filesystem] &&
          quota.object_name == resources[name][:object_name]
      end
      next unless provider
      resources[name].provider = provider
    end
  end

  def create
    raise("Filesystem is mandatory for #{resource.type} #{resource.name}") if resource[:filesystem].nil?

    data = {}
    data[:operationType] = 'setQuota'
    data[:quotaType] = resource[:type]
    data[:objectName] = resource[:object_name]
    data[:blockSoftLimit] = resource[:block_soft_limit] if resource[:block_soft_limit]
    data[:blockHardLimit] = resource[:block_hard_limit] if resource[:block_hard_limit]
    data[:filesSoftLimit] = resource[:files_soft_limit] if resource[:files_soft_limit]
    data[:filesHardLimit] = resource[:files_hard_limit] if resource[:files_hard_limit]
    uri_path = "v2/filesystems/#{resource[:filesystem]}/filesets/#{resource[:fileset]}/quotas"

    begin
      post_request(uri_path, data)
    rescue Exception => e # rubocop:disable Lint/RescueException
      raise Puppet::Error, "POST to #{uri_path} failed\nError message: #{e.message}"
    end

    @property_hash[:ensure] = :present
  end

  def destroy
    raise("Filesystem is mandatory for #{resource.type} #{resource.name}") if resource[:filesystem].nil?

    data = {}
    data[:operationType] = 'setQuota'
    data[:quotaType] = resource[:type]
    data[:objectName] = resource[:object_name]
    data[:blockSoftLimit] = '0'
    data[:blockHardLimit] = '0'
    data[:filesSoftLimit] = 0
    data[:filesHardLimit] = 0
    uri_path = "v2/filesystems/#{resource[:filesystem]}/filesets/#{resource[:fileset]}/quotas"

    begin
      post_request(uri_path, data)
    rescue Exception => e # rubocop:disable Lint/RescueException
      raise Puppet::Error, "POST to #{uri_path} failed\nError message: #{e.message}"
    end
    @property_hash.clear
  end

  def exists?
    @property_hash[:ensure] == :present &&
      !(@property_hash[:block_soft_limit] == '0' &&
         @property_hash[:block_hard_limit] == '0' &&
         @property_hash[:files_soft_limit].zero? &&
         @property_hash[:files_hard_limit].zero?
       )
  end

  def initialize(value = {})
    super(value)
    @property_flush = {}
  end

  def block_soft_limit=(value)
    @property_flush[:block_soft_limit] = value
  end

  def block_hard_limit=(value)
    @property_flush[:block_hard_limit] = value
  end

  def files_soft_limit=(value)
    @property_flush[:files_soft_limit] = value
  end

  def files_hard_limit=(value)
    @property_flush[:files_hard_limit] = value
  end

  def flush
    raise("Filesystem is mandatory for #{resource.type} #{resource.name}") if resource[:filesystem].nil?
    unless @property_flush.empty?
      data = {}
      data[:operationType] = 'setQuota'
      data[:quotaType] = resource[:type]
      data[:objectName] = resource[:object_name]
      data[:blockSoftLimit] = @property_flush[:block_soft_limit] if @property_flush[:block_soft_limit]
      data[:blockHardLimit] = @property_flush[:block_hard_limit] if @property_flush[:block_hard_limit]
      data[:filesSoftLimit] = @property_flush[:files_soft_limit] if @property_flush[:files_soft_limit]
      data[:filesHardLimit] = @property_flush[:files_hard_limit] if @property_flush[:files_hard_limit]
      uri_path = "v2/filesystems/#{resource[:filesystem]}/filesets/#{resource[:fileset]}/quotas"

      begin
        post_request(uri_path, data)
      rescue Exception => e # rubocop:disable Lint/RescueException
        raise Puppet::Error, "POST to #{uri_path} failed\nError message: #{e.message}"
      end
    end
    # Collect the resources again once they've been changed (that way `puppet
    # resource` will show the correct values after changes have been made).
    @property_hash = resource.to_hash
  end
end
