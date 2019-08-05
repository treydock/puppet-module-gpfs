# Private class.
class gpfs::install {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  $_package_defaults = {
    'ensure' => $gpfs::package_ensure
  }

  if $gpfs::manage_packages {
    ensure_packages($gpfs::packages, $_package_defaults)
  }

}
