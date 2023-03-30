# @summary Manage GPFS repo
# @api private
class gpfs::repo {
  assert_private()

  if $facts['os']['family'] == 'RedHat' and $gpfs::repo_baseurl {
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
