Puppet::Type.newtype(:gpfs_fileset_quota) do
  @doc = "Set a GPFS fileset quota'

    Example:

      gpfs_fileset_quota { 'test':
        filesystem => 'project',
        block_soft_limit  => '5T',
        block_hard_limit  => '5T',
        files_soft_limit  => 1000000,
        files_hard_limit  => 1000000,
      }
  "

  ensurable

  newparam(:name) do
    desc 'The default namevar'
  end

  newparam(:filesystem) do
    desc 'The GPFS filesystem name.'
  end

  newparam(:fileset) do
    desc 'The GPFS fileset name.'
    defaultto do
      @resource[:name]
    end
  end

  newparam(:object_name) do
    desc 'The GPFS quota object name'
    defaultto do
      @resource[:name]
    end
  end

  newparam(:type) do
    desc 'Quota type'
    defaultto(:fileset)

    validate do |value|
      valid_values = [:usr, :grp, :fileset]
      unless valid_values.include?(value.downcase.to_sym)
        raise ArgumentError, "Invalid type #{value}. Valid values are #{valid_values.join(', ')}"
      end
    end

    munge do |value|
      value.downcase.to_sym
    end
  end

  newproperty(:block_soft_limit) do
    desc 'blockSoftLimit of quota'

    validate do |value|
      unless value =~ %r{^0$|^([0-9\.]+)(M|G|T)$}
        raise ArgumentError, "Invalid block_soft_limit: #{value}, must be in format of [0-9]+(M|G|T)"
      end
    end
  end

  newproperty(:block_hard_limit) do
    desc 'blockHardLimit of quota'

    validate do |value|
      unless value =~ %r{^0$|^([0-9\.]+)(M|G|T)$}
        raise ArgumentError, "Invalid block_hard_limit: #{value}, must be in format of [0-9]+(M|G|T)"
      end
    end
  end

  newproperty(:files_soft_limit) do
    desc 'filesSoftLimit of quota'

    munge do |value|
      resource.class.convert_files(value).to_i
    end
  end

  newproperty(:files_hard_limit) do
    desc 'filesHardLimit of quota'

    munge do |value|
      resource.class.convert_files(value).to_i
    end
  end

  autorequire(:gpfs_fileset) do
    [self[:fileset]]
  end

  autorequire(:service) do
    ['gpfsgui']
  end

  def self.convert_block(value)
    factors = {
      'M' => 1024,
      'G' => 1024**2,
      'T' => 1024**3,
    }
    if value =~ %r{^([0-9\.])(T|G|M)$} # rubocop:disable Style/GuardClause
      v = Regexp.last_match(1).to_f
      f = Regexp.last_match(2)
      factor = factors[f]
      return (v * factor)
    else
      return value
    end
  end

  def self.convert_files(value)
    factors = {
      'M' => 10**6,
      'K' => 10**3,
    }
    if value =~ %r{^(\d+)(M|K)$} # rubocop:disable Style/GuardClause
      v = Regexp.last_match(1).to_i
      f = Regexp.last_match(2)
      factor = factors[f]
      return (v * factor)
    else
      return value
    end
  end
end
