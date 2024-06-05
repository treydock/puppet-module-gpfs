# frozen_string_literal: true

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'gpfs'))
require 'etc'
require 'uri'

Puppet::Type.type(:gpfs_audit).provide(:shell, parent: Puppet::Provider::Gpfs) do
  desc ''

  mk_resource_methods

  defaultfor osfamily: :redhat

  commands mmaudit: '/usr/lpp/mmfs/bin/mmaudit'

  def self.instances
    audits = []
    mmaudit_output = mmaudit('all', 'list', '-Y')
    mmaudit_output.each_line do |line|
      audit = {}
      l = line.strip
      next if l.nil?
      next if l =~ %r{disabled for all devices}

      l = l.split(':')
      next if l[2] == 'HEADER'
      next if l.size < 14

      audit[:ensure] = :present
      audit[:compliant] = if l[6] == 'noncompliant'
                            :false
                          else
                            :true
                          end
      audit[:filesystem] = l[7]
      audit[:name] = audit[:filesystem]
      audit[:log_fileset] = l[10]
      audit[:retention] = l[11].to_i
      all_events = 'ACCESS_DENIED,ACLCHANGE,CLOSE,CREATE,GPFSATTRCHANGE,OPEN,RENAME,RMDIR,UNLINK,XATTRCHANGE'
      audit[:events] = if l[13] == all_events
                         ['ALL']
                       else
                         l[13].split(',')
                       end
      if l[15] == 'FILESET'
        audit[:filesets] = l[16].split(',')
      end
      if l[15] == 'SKIPFILESET'
        audit[:skip_filesets] = l[16].split(',')
      end
      audits << new(audit)
    end
    audits
  end

  def self.prefetch(resources)
    audits = instances
    resources.each_key do |name|
      provider = audits.find do |audit|
        audit.filesystem == resources[name][:filesystem]
      end
      next unless provider

      resources[name].provider = provider
    end
  end

  def create
    mmaudit_args = [
      resource[:filesystem], 'enable',
      '--log-fileset', resource[:log_fileset],
      '--retention', resource[:retention].to_s,
      '--events', resource[:events].join(',')
    ]
    if resource[:compliant].to_sym == :true
      mmaudit_args << '--compliant'
    end
    if !resource[:filesets].nil? && !resource[:filesets].empty?
      mmaudit_args << '--filesets'
      mmaudit_args << resource[:filesets].join(',')
    end
    if !resource[:skip_filesets].nil? && !resource[:skip_filesets].empty?
      mmaudit_args << '--skip-filesets'
      mmaudit_args << resource[:skip_filesets].join(',')
    end
    mmaudit(mmaudit_args)
    @property_hash[:ensure] = :present
  end

  def destroy
    mmaudit([resource[:filesystem], 'disable'])

    @property_hash.clear
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def initialize(value = {})
    super(value)
    @property_flush = {}
  end

  type_properties.each do |prop|
    define_method "#{prop}=".to_sym do |value|
      @property_flush[prop] = value
    end
  end

  def flush
    if @property_flush[:events]
      mmaudit([resource[:filesystem], 'update', '--events', @property_flush[:events].join(',')])
    end
    if @property_flush[:filesets]
      enable_filesets = @property_flush[:filesets].sort - @property_hash[:filesets].sort
      unless enable_filesets.empty?
        mmaudit([resource[:filesystem], 'update', '--enable-filesets', enable_filesets.join(',')])
      end
      if resource[:disable_missing].to_sym == :true
        disable_filesets = @property_hash[:filesets] - @property_flush[:filesets]
        unless disable_filesets.empty?
          mmaudit([resource[:filesystem], 'update', '--disable-filesets', disable_filesets.join(',')])
        end
      end
    end
    if @property_flush[:skip_filesets]
      disable_filesets = @property_flush[:skip_filesets].sort - @property_hash[:skip_filesets].sort
      mmaudit([resource[:filesystem], 'update', '--disable-filesets', disable_filesets.join(',')])
    end
    # Collect the resources again once they've been changed (that way `puppet
    # resource` will show the correct values after changes have been made).
    @property_hash = resource.to_hash
  end
end
