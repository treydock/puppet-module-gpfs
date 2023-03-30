# @summary Manage GPFS NSD config
# @api private
class gpfs::server::config {
  assert_private()

  $bin_paths = $gpfs::server::bin_paths
  file { '/etc/profile.d/gpfs.sh':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('gpfs/gpfs.sh.profile.erb'),
  }
}
