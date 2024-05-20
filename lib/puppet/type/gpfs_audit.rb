# frozen_string_literal: true

require_relative '../../puppet_x/gpfs/array_property'

Puppet::Type.newtype(:gpfs_audit) do
  desc <<-DESC
@summary Manage a GPFS filesystem audit

@example Enable audit on `test` filesystem
  gpfs_audit { 'test':
    filesystem  => 'test',
    retention   => 25,
    filesets    => ['foo'],
  }

  DESC

  ensurable

  newparam(:name, namevar: true) do
    desc 'The default namevar.'
  end

  newparam(:filesystem) do
    desc 'The GPFS filesystem name.'
    defaultto do
      @resource[:name]
    end
  end

  newparam(:log_fileset) do
    desc 'The GPFS audit log fileset.'
    defaultto '.audit_log'
  end

  newparam(:retention) do
    desc 'The retention in days'
    defaultto 365

    validate do |value|
      if value && value.to_s != value.to_i.to_s
        raise ArgumentError, 'Expected an integer for retention'
      end
    end
    munge do |value|
      value.to_i
    end
  end

  newproperty(:events, array_matching: :all, parent: PuppetX::GPFS::ArrayProperty) do
    desc 'Audit events'
    defaultto ['ALL']
  end

  newparam(:compliant, boolean: true) do
    desc 'Set audit fileset as compliant'
    newvalues(:true, :false)
    defaultto :false
  end

  newproperty(:filesets, array_matching: :all, parent: PuppetX::GPFS::ArrayProperty) do
    desc 'Filesets to audit'
  end

  newproperty(:skip_filesets, array_matching: :all, parent: PuppetX::GPFS::ArrayProperty) do
    desc 'Filesets to skip audit'
  end

  validate do
    raise('Filesystem is required.') if self[:filesystem].nil?
    if !self[:filesets].nil? && !self[:skip_filesets].nil?
      raise('filesets and skip_filesets are mutually exclusive')
    end
  end

  autorequire(:gpfs_fileset) do
    requires = []
    catalog.resources.each do |resource|
      next if self[:filesets].nil?
      next unless resource.instance_of?(Puppet::Type::Gpfs_fileset)
      next if self[:filesystem] != resource[:filesystem]

      if self[:filesets].include?(resource[:fileset])
        requires << resource.name
      end
    end
    requires
  end
end
