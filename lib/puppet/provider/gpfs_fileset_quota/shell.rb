require File.expand_path(File.join(File.dirname(__FILE__), '..', 'gpfs'))

Puppet::Type.type(:gpfs_fileset_quota).provide(:shell, parent: Puppet::Provider::Gpfs) do
  desc ''

  mk_resource_methods

  defaultfor osfamily: :redhat

  commands mmlsfs: '/usr/lpp/mmfs/bin/mmlsfs'
  commands mmrepquota: '/usr/lpp/mmfs/bin/mmrepquota'
  commands mmsetquota: '/usr/lpp/mmfs/bin/mmsetquota'

  def self.instances
    quotas = []
    mmlsfs_filesystems.each do |filesystem|
      mmrepquota_output = mmrepquota('-Y', filesystem)
      mmrepquota_output.each_line do |line|
        quota = {}
        l = line.strip.split(':')
        next if l[2] == 'HEADER'
        type = l[7].downcase
        quota[:ensure] = :present
        quota[:filesystem] = filesystem
        quota[:fileset] = if type == 'fileset'
                            l[9]
                          else
                            l[24]
                          end
        quota[:type] = type.to_sym
        quota[:object_name] = l[9]
        quota[:name] = "#{quota[:filesystem]}/#{quota[:fileset]}/#{type}/#{quota[:object_name]}"
        quota[:block_soft_limit] = human_readable_kilobytes(l[11].to_i)
        quota[:block_hard_limit] = human_readable_kilobytes(l[12].to_i)
        quota[:files_soft_limit] = l[16].to_i
        quota[:files_hard_limit] = l[17].to_i
        quotas << new(quota)
      end
    end
    quotas
  end

  def self.prefetch(resources)
    quotas = instances
    resources.keys.each do |name|
      provider = quotas.find do |quota|
        quota.fileset == resources[name][:fileset] &&
          quota.filesystem == resources[name][:filesystem] &&
          quota.object_name == resources[name][:object_name] &&
          quota.type == resources[name][:type]
      end
      next unless provider
      resources[name].provider = provider
    end
  end

  def create
    raise("Filesystem is mandatory for #{resource.type} #{resource.name}") if resource[:filesystem].nil?

    # mmsetquota project:PAS1172 --block 3T:3T --files 600000:600000

    mmsetquota_args = ["#{resource[:filesystem]}:#{resource[:fileset]}"]
    if resource[:type] == :usr
      mmsetquota_args << '--user'
      mmsetquota_args << resource[:object_name]
    end
    if resource[:type] == :grp
      mmsetquota_args << '--group'
      mmsetquota_args << resource[:object_name]
    end
    if resource[:block_soft_limit] && resource[:block_hard_limit]
      mmsetquota_args << '--block'
      mmsetquota_args << "#{self.class.to_kb(resource[:block_soft_limit])}:#{self.class.to_kb(resource[:block_hard_limit])}"
    elsif resource[:block_soft_limit]
      mmsetquota_args << '--block'
      mmsetquota_args << self.class.to_kb(resource[:block_soft_limit])
    end
    if resource[:files_soft_limit] && resource[:files_hard_limit]
      mmsetquota_args << '--files'
      mmsetquota_args << "#{resource[:files_soft_limit]}:#{resource[:files_hard_limit]}"
    elsif resource[:files_soft_limit]
      mmsetquota_args << '--files'
      mmsetquota_args << resource[:files_soft_limit]
    end

    mmsetquota(mmsetquota_args)

    @property_hash[:ensure] = :present
  end

  def destroy
    raise("Filesystem is mandatory for #{resource.type} #{resource.name}") if resource[:filesystem].nil?

    mmsetquota_args = ["#{resource[:filesystem]}:#{resource[:fileset]}"]
    mmsetquota_args << '--block'
    mmsetquota_args << '0:0'
    mmsetquota_args << '--files'
    mmsetquota_args << '0:0'
    mmsetquota(mmsetquota_args)

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
    @property_flush[:block_soft_limit] = self.class.to_kb(value)
  end

  def block_hard_limit=(value)
    @property_flush[:block_hard_limit] = self.class.to_kb(value)
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
      mmsetquota_args = ["#{resource[:filesystem]}:#{resource[:fileset]}"]
      if resource[:type] == :usr
        mmsetquota_args << '--user'
        mmsetquota_args << resource[:object_name]
      end
      if resource[:type] == :grp
        mmsetquota_args << '--group'
        mmsetquota_args << resource[:object_name]
      end
      if @property_flush[:block_soft_limit] && @property_flush[:block_hard_limit]
        mmsetquota_args << '--block'
        mmsetquota_args << "#{@property_flush[:block_soft_limit]}:#{@property_flush[:block_hard_limit]}"
      elsif @property_flush[:block_soft_limit]
        mmsetquota_args << '--block'
        mmsetquota_args << @property_flush[:block_soft_limit]
      elsif @property_flush[:block_hard_limit]
        mmsetquota_args << '--block'
        mmsetquota_args << "#{self.class.to_kb(@property_hash[:block_soft_limit])}:#{@property_flush[:block_hard_limit]}"
      end
      if @property_flush[:files_soft_limit] && @property_flush[:files_hard_limit]
        mmsetquota_args << '--files'
        mmsetquota_args << "#{@property_flush[:files_soft_limit]}:#{@property_flush[:files_hard_limit]}"
      elsif @property_flush[:files_soft_limit]
        mmsetquota_args << '--files'
        mmsetquota_args << @property_flush[:files_soft_limit]
      elsif @property_flush[:files_hard_limit]
        mmsetquota_args << '--files'
        mmsetquota_args << "#{@property_hash[:files_soft_limit]}:#{@property_flush[:files_hard_limit]}"
      end

      mmsetquota(mmsetquota_args)
    end
    # Collect the resources again once they've been changed (that way `puppet
    # resource` will show the correct values after changes have been made).
    @property_hash = resource.to_hash
  end
end
