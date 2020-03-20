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
# @param config_filesystems
#   Filesystems where filesets are managed by Puppet
#
class gpfs (
  Boolean $manage_repo = true,
  Optional[String] $repo_baseurl = undef,
  Boolean $manage_packages  = true,
  String $package_ensure    = 'present',
  Array $packages           = [ "gpfs.gplbin-${facts['kernelrelease']}",
    'gpfs.adv',
    'gpfs.base',
    'gpfs.crypto',
    'gpfs.docs',
    'gpfs.ext',
    'gpfs.gpl',
    'gpfs.gskit',
    'gpfs.msg.en_US',
  ],
  Optional[Array] $config_filesystems = undef,
) {

  $osfamily = dig($facts, 'os', 'family')
  if ! ($osfamily in ['RedHat']) {
    fail("Unsupported OS: ${osfamily}, module ${module_name} only supports RedHat")
  }

  contain gpfs::install

  if $manage_repo {
    contain gpfs::repo
    Class['gpfs::repo'] -> Class['gpfs::install']
  }

  gpfs_config { 'puppet':
    filesystems => $config_filesystems,
  }
}
