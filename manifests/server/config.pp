# @summary Manage GPFS NSD config
# @api private
class gpfs::server::config {

  file { '/etc/profile.d/gpfs.sh':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('gpfs/server/gpfs.sh.profile.erb')
  }

}
