# See README.md for more details.
class gpfs::server (
  Boolean $manage_packages  = true,
  String $package_ensure    = 'present',
  Array $packages           = $gpfs::params::server_packages,
  Array $bin_paths          = ['/usr/lpp/mmfs/bin'],
) inherits gpfs::params {

  contain gpfs
  contain gpfs::server::install
  contain gpfs::server::config

  Class['gpfs']
  ->Class['gpfs::server::install']
  ->Class['gpfs::server::config']

}
