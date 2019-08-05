# See README.md for more details.
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
