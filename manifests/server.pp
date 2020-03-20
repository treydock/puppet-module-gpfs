# @summary GPFS server class
#
# @example
#   include ::gpfs::server
#
# @param manage_packages
#   Determines if GPFS server packages should be managed
# @param package_ensure
#   GPFS server package ensure property
# @param packages
#   GPFS server packages
# @param bin_paths
#   Paths to add to PATH
#
class gpfs::server (
  Boolean $manage_packages  = true,
  String $package_ensure    = 'present',
  Array $packages           = [],
  Array[Stdlib::Absolutepath] $bin_paths = ['/usr/lpp/mmfs/bin'],
) {

  contain gpfs
  contain gpfs::server::install
  contain gpfs::server::config

  Class['gpfs']
  ->Class['gpfs::server::install']
  ->Class['gpfs::server::config']

}
