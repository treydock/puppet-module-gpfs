# Private class.
class gpfs::client::install {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  $_package_defaults = {
    'ensure' => $gpfs::client::package_ensure
  }

  if $gpfs::client::manage_packages {
    ensure_packages($gpfs::client::packages, $_package_defaults)
  }

}
