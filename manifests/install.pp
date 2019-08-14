# @summary Manage GPFS installs
# @api private
class gpfs::install {
  assert_private()

  if $gpfs::manage_packages {
    $gpfs::packages.each |$package| {
      package { $package:
        ensure => $gpfs::package_ensure,
      }
    }
  }

}
