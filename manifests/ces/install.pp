# @summary Manage GPFS CES install
# @api private
class gpfs::ces::install {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  $_package_defaults = {
    'ensure' => $gpfs::ces::package_ensure
  }

  if $gpfs::ces::manage_packages {
    ensure_packages($gpfs::ces::packages, $_package_defaults)
  }

}
