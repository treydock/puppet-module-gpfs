# @summary Manage GPFS GUI install
# @api private
class gpfs::gui::install {
  assert_private()

  if $gpfs::gui::manage_packages {
    $gpfs::gui::packages.each |$package| {
      package { $package:
        ensure => $gpfs::gui::package_ensure,
        notify => Exec['/usr/lpp/mmfs/gui/cli/initgui'],
      }
    }
  }

}
