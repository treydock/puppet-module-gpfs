# See README.md for more details.
class gpfs::gui (
  Boolean $manage_packages  = true,
  String $package_ensure    = 'present',
  Array $packages           = $gpfs::params::gui_packages,
  Boolean $manage_firewall  = true,
  Optional[Variant[String, Array]] $firewall_source = undef,
) inherits gpfs::params {

  contain gpfs
  contain gpfs::gui::install
  contain gpfs::gui::config
  contain gpfs::gui::service

  Class['gpfs']
  ->Class['gpfs::gui::install']
  ->Class['gpfs::gui::config']
  ->Class['gpfs::gui::service']

}
