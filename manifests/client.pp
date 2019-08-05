# See README.md for more details.
class gpfs::client (
  Boolean $manage_packages = true,
  $package_ensure       = 'present',
  $packages             = $gpfs::params::client_packages,
  Boolean $manage_ssh_authorized_keys = true,
  $ssh_user             = 'root',
  $ssh_authorized_keys  = {},
  $rkms                 = {},
) inherits gpfs::params {

  contain gpfs
  contain gpfs::client::install
  contain gpfs::client::config

  Class['gpfs']
  ->Class['gpfs::client::install']
  ->Class['gpfs::client::config']

}
