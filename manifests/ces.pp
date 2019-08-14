# @summary GPFS CES class
#
# @example
#   include ::gpfs::ces
#
# @param manage_packages
#   Determines if GPFS CES packages should be managed
# @param package_ensure
#   GPFS CES package ensure property
# @param packages
#   GPFS CES packages
class gpfs::ces (
  Boolean $manage_packages  = true,
  String $package_ensure    = 'present',
  Array $packages           = [
    'gpfs.java',
    'gpfs.smb',
    'nfs-ganesha',
    'nfs-ganesha-gpfs',
    'nfs-ganesha-utils',
  ],
) {

  contain gpfs
  contain gpfs::ces::install
  contain gpfs::ces::config

  Class['gpfs']
  ->Class['gpfs::ces::install']
  ->Class['gpfs::ces::config']

}
