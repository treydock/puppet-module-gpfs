# @summary Manage GPFS CES install
# @api private
class gpfs::ces::install {
  assert_private()

  if $gpfs::ces::manage_packages {
    $gpfs::ces::packages.each |$package| {
      package { $package:
        ensure => $gpfs::ces::package_ensure,
      }
    }
  }


}
