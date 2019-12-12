# @summary Manage GPFS NSD config
# @api private
class gpfs::server::config {
  assert_private()

  file { '/etc/profile.d/gpfs.sh':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('gpfs/server/gpfs.sh.profile.erb')
  }

  gpfs_config { 'puppet':
    filesystems => $gpfs::server::config_filesystems,
  }

}