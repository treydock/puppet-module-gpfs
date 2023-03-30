# @summary Manage GPFS NSD install
# @api private
class gpfs::server::install {
  assert_private()

  if $gpfs::server::manage_packages {
    $gpfs::server::packages.each |$package| {
      package { $package:
        ensure => $gpfs::server::package_ensure,
      }
    }
  }
}
