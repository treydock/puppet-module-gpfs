# @summary GPFS GUI class
#
# @example
#   include ::gpfs::gui
#
# @param manage_packages
#   Determines if GPFS GUI packages should be managed
# @param package_ensure
#   GPFS GUI package ensure property
# @param packages
#   GPFS GUI packages
# @param manage_firewall
#   Determines if firewall should be managed
# @param firewall_source
#   Firewall source value
class gpfs::gui (
  Boolean $manage_packages  = true,
  String $package_ensure    = 'present',
  Array $packages           = [
    'gpfs.gui',
  ],
  Boolean $manage_firewall  = true,
  Optional[Variant[String, Array]] $firewall_source = undef,
) {

  contain gpfs
  contain gpfs::gui::install
  contain gpfs::gui::config
  contain gpfs::gui::service

  Class['gpfs']
  ->Class['gpfs::gui::install']
  ->Class['gpfs::gui::config']
  ->Class['gpfs::gui::service']

}
