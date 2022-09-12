# @summary GPFS client class
#
# @example
#   include ::gpfs::client
#
# @param manage_packages
#   Determines if GPFS client packages should be managed
# @param package_ensure
#   GPFS client package ensure property
# @param packages
#   GPFS client packages
# @param manage_service_files
#  Determines if GPFS service files are managed
# @param manage_ssh_authorized_keys
#   Determines if SSH authorized_keys should be managed
# @param ssh_user
#   SSH user for GPFS
# @param ssh_authorized_keys
#   SSH authorized keys for NSDs
# @param rkms
#   Hash to define gpfs::client::rkm resources
# @param bin_paths
#   Paths to add to PATH
class gpfs::client (
  Boolean $manage_packages = true,
  $package_ensure       = 'present',
  $packages             = [],
  Boolean $manage_service_files = true,
  Boolean $manage_ssh_authorized_keys = true,
  $ssh_user             = 'root',
  $ssh_authorized_keys  = {},
  $rkms                 = {},
  Array[Stdlib::Absolutepath] $bin_paths  = [],
) {

  contain gpfs
  contain gpfs::client::install
  contain gpfs::client::config

  Class['gpfs']
  ->Class['gpfs::client::install']
  ->Class['gpfs::client::config']

}
