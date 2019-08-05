hosts.each do |h|
  install_puppet_module_via_pmt_on(h, :module_name => 'puppetlabs-inifile')
end

RSpec.configure do |c|
  c.add_setting :gpfs_repo_url, :default => nil
  c.gpfs_repo_url = ENV['BEAKER_gpfs_repo_url']
end
hosts.each do |h|
  puppet_pp = <<-EOF
  ini_setting { 'puppet.conf/main/show_diff':
    ensure  => 'present',
    section => 'main',
    path    => '/etc/puppetlabs/puppet/puppet.conf',
    setting => 'show_diff',
    value   => 'true',
  }
EOF
  apply_manifest_on(h, puppet_pp, :catch_failures => true)
  yumrepo_pp = <<-EOS
  yumrepo { 'gpfs':
    ensure    => 'present',
    baseurl   => '#{RSpec.configuration.gpfs_repo_url}',
    descr     => 'gpfs',
    enabled   => '1',
    gpgcheck  => '0',
  }
  EOS
  if RSpec.configuration.gpfs_repo_url
    apply_manifest_on(h, yumrepo_pp, :catch_failures => true)
  end
end
