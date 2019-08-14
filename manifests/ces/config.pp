# @summary Manage GPFS CES config
# @api private
class gpfs::ces::config {
  assert_private()

  logrotate::rule { 'ganesha':
    path         => '/var/log/ganesha.log',
    compress     => true,
    missingok    => true,
    copytruncate => true,
    dateext      => true,
  }

  logrotate::rule { 'scstadmin':
    path         => '/var/log/scstadmin.log',
    compress     => true,
    missingok    => true,
    copytruncate => true,
    dateext      => true,
  }

  sudo::conf { 'ctdb':
    sudo_file_name => 'ctdb',
    content        => [
      'Defaults!/usr/lpp/mmfs/lib/ctdb/statd-callout   !requiretty',
      'rpcuser         ALL=(ALL)       NOPASSWD: /usr/lpp/mmfs/lib/ctdb/statd-callout',
    ]
  }

}
