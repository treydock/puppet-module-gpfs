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
# @param firewall_https_only
#   Only manage firewall rules for HTTPS
# @param manage_services
#   Determines if services are managed
# @param manage_initgui
#   Determines if manage Exec to initialize GUI
class gpfs::gui (
  Boolean $manage_packages  = true,
  String $package_ensure    = 'present',
  Array $packages           = [
    'gpfs.gui',
  ],
  Boolean $manage_firewall  = true,
  Optional[Variant[String, Array, Boolean]] $firewall_source = undef,
  Boolean $firewall_https_only = false,
  Boolean $manage_services = true,
  Boolean $manage_initgui = true,
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
