# Private class.
class gpfs::repo {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $gpfs::repo_baseurl and $gpfs::manage_repo {
    yumrepo { 'gpfs':
      descr           => 'RPMS for GPFS',
      baseurl         => $gpfs::repo_baseurl,
      enabled         => '1',
      metadata_expire => '1',
      gpgcheck        => '0',
      priority        => '1',
    }
  }

}
