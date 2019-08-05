# Private class.
class gpfs::client::config {

  $_ssh_authorized_key_defaults = {
    'type' => 'ssh-rsa',
    'user' => $gpfs::client::ssh_user,
  }

  if $gpfs::client::manage_ssh_authorized_keys {
    create_resources('ssh_authorized_key', $gpfs::client::ssh_authorized_keys, $_ssh_authorized_key_defaults)
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
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    require => File['/var/mmfs/etc'],
  }

  concat::fragment { 'RKM.conf.header':
    target  => '/var/mmfs/etc/RKM.conf',
    content => template('gpfs/RKM.conf.header.erb'),
    order   => '01',
  }

  create_resources('gpfs::client::rkm', $gpfs::client::rkms)

  # Hack to properly install systemd service
  if $::service_provider == 'systemd' {
    file { '/etc/systemd/system/gpfs.service':
      ensure => 'file',
      owner  => 'root',
      group  => 'root',
      mode   => '0444',
      source => 'file:///usr/lpp/mmfs/lib/systemd/gpfs.service',
    }
  }

}
