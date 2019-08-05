# See README.md for more details.
class gpfs::ces (
  Boolean $manage_packages  = true,
  String $package_ensure    = 'present',
  Array $packages           = $gpfs::params::ces_packages,
) inherits gpfs::params {

  contain gpfs
  contain gpfs::ces::install
  contain gpfs::ces::config

  Class['gpfs']
  ->Class['gpfs::ces::install']
  ->Class['gpfs::ces::config']

}
