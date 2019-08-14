# @summary Manage GPFS GUI install
# @api private
class gpfs::gui::install {
  assert_private()

  $_package_defaults = {
    'ensure' => $gpfs::gui::package_ensure,
    'notify' => Exec['/usr/lpp/mmfs/gui/cli/initgui'],
  }

  if $gpfs::gui::manage_packages {
    ensure_packages($gpfs::gui::packages, $_package_defaults)
  }

}
