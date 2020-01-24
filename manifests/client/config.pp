# @summary Manage GPFS client config
# @api private
class gpfs::client::config {
  assert_private()

  $_ssh_authorized_key_defaults = {
    'type' => 'ssh-rsa',
    'user' => $gpfs::client::ssh_user,
  }

  if $gpfs::client::manage_ssh_authorized_keys {
    create_resources('ssh_authorized_key', $gpfs::client::ssh_authorized_keys, $_ssh_authorized_key_defaults)
  }

  $bin_paths = $gpfs::client::bin_paths
  if ! empty($bin_paths) {
    $gpfs_sh_ensure = 'file'
  } else {
    $gpfs_sh_ensure = 'absent'
  }
  file { '/etc/profile.d/gpfs-client.sh':
    ensure  => $gpfs_sh_ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('gpfs/gpfs.sh.profile.erb')
  }

  file { '/var/mmfs/ccr':
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { '/var/mmfs/ccr/committed':
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { '/var/mmfs/etc':
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  concat { '/var/mmfs/etc/RKM.conf':
    ensure    => 'present',
    owner     => 'root',
    group     => 'root',
    mode      => '0600',
    show_diff => false,
    require   => File['/var/mmfs/etc'],
  }

  concat::fragment { 'RKM.conf.header':
    target  => '/var/mmfs/etc/RKM.conf',
    content => template('gpfs/RKM.conf.header.erb'),
    order   => '01',
  }

  create_resources('gpfs::client::rkm', $gpfs::client::rkms)

  # Hack to properly install systemd service
  if $::service_provider == 'systemd' {
    file { '/usr/lib/systemd/system/gpfs.service':
      ensure => 'file',
      owner  => 'root',
      group  => 'root',
      mode   => '0444',
      source => 'file:///usr/lpp/mmfs/lib/systemd/gpfs.service',
    }
    file { '/etc/systemd/system/gpfs.service':
      ensure => 'absent',
      notify => Exec['gpfs-systemctl-daemon-reload'],
    }
    exec { 'gpfs-systemctl-daemon-reload':
      path        => '/usr/bin:/bin:/usr/sbin:/sbin',
      command     => 'systemctl daemon-reload',
      refreshonly => true,
      notify      => Exec['gpfs-fix-systemd-enable'],
    }
    exec { 'gpfs-fix-systemd-enable':
      path        => '/usr/bin:/bin:/usr/sbin:/sbin',
      command     => 'systemctl disable gpfs ; systemctl enable gpfs',
      onlyif      => 'systemctl is-enabled gpfs',
      refreshonly => true,
    }
  }

}
