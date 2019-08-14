# @summary Manage GPFS NSD install
# @api private
class gpfs::server::install {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  $_package_defaults = {
    'ensure' => $gpfs::server::package_ensure
  }

  if $gpfs::server::manage_packages {
    ensure_packages($gpfs::server::packages, $_package_defaults)
  }

}
