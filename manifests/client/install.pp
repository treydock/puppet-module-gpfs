# @summary Manage GPFS client install
# @api private
class gpfs::client::install {
  assert_private()

  if $gpfs::client::manage_packages {
    $gpfs::client::packages.each |$package| {
      package { $package:
        ensure => $gpfs::client::package_ensure,
      }
    }
  }

}
