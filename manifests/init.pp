# @summary base GPFS class
#
# @example
#   include ::gpfs
#
# @param manage_repo
#   Sets if GPFS repo should be managed
# @param repo_baseurl
#   The GPFS repo baseurl
# @param manage_packages
#   Determines if GPFS packages should be managed
# @param package_ensure
#   GPFS package ensure property
# @param packages
#   GPFS base packages
class gpfs (
  Boolean $manage_repo = true,
  Optional[String] $repo_baseurl = undef,
  Boolean $manage_packages  = true,
  String $package_ensure    = 'present',
  Array $packages           = $gpfs::params::packages,
) inherits gpfs::params {

  contain gpfs::repo
  contain gpfs::install

  Class['gpfs::repo']
  -> Class['gpfs::install']

}
