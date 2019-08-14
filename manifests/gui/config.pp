# @summary Manage GPFS GUI config
# @api private
class gpfs::gui::config {
  assert_private()

  file { '/etc/sudoers.d/scalemgmt_sudoers':
    ensure => 'file',
    owner  => 'root',
    group  => 'root',
    mode   => '0440'
  }

  if $gpfs::gui::manage_firewall {
    case $gpfs::gui::firewall_source {
      String: {
        firewall { "47443 ${gpfs::gui::firewall_source}:47443":
          ensure  => 'present',
          action  => 'accept',
          chain   => 'INPUT',
          ctstate => ['NEW'],
          dport   => '47443',
          proto   => 'tcp',
          source  => $gpfs::gui::firewall_source,
        }
        firewall { "47080 ${gpfs::gui::firewall_source}:47080":
          ensure  => 'present',
          action  => 'accept',
          chain   => 'INPUT',
          ctstate => ['NEW'],
          dport   => '47080',
          proto   => 'tcp',
          source  => $gpfs::gui::firewall_source,
        }
      }
      Array: {
        $gpfs::gui::firewall_source.each |$source| {
          firewall { "47443 ${source}:47443":
            ensure  => 'present',
            action  => 'accept',
            chain   => 'INPUT',
            ctstate => ['NEW'],
            dport   => '47443',
            proto   => 'tcp',
            source  => $source,
          }
          firewall { "47080 ${source}:47080":
            ensure  => 'present',
            action  => 'accept',
            chain   => 'INPUT',
            ctstate => ['NEW'],
            dport   => '47080',
            proto   => 'tcp',
            source  => $source,
          }
        }
      }
      default: {
        firewall { '47443 *:47443':
          ensure  => 'present',
          action  => 'accept',
          chain   => 'INPUT',
          ctstate => ['NEW'],
          dport   => '47443',
          proto   => 'tcp',
        }
        firewall { '47080 *:47080':
          ensure  => 'present',
          action  => 'accept',
          chain   => 'INPUT',
          ctstate => ['NEW'],
          dport   => '47080',
          proto   => 'tcp',
        }
      }
    }
    firewall { '443 PREROUTING REDIRECT TO 47443':
      ensure  => 'present',
      chain   => 'PREROUTING',
      dport   => '443',
      jump    => 'REDIRECT',
      proto   => 'tcp',
      table   => 'nat',
      toports => '47443',
    }
    firewall { '80 PREROUTING REDIRECT TO 47080':
      ensure  => 'present',
      chain   => 'PREROUTING',
      dport   => '80',
      jump    => 'REDIRECT',
      proto   => 'tcp',
      table   => 'nat',
      toports => '47080',
    }
    firewall { '443 OUTPUT REDIRECT TO 47443':
      ensure   => 'present',
      chain    => 'OUTPUT',
      dport    => '443',
      jump     => 'REDIRECT',
      outiface => 'lo',
      proto    => 'tcp',
      table    => 'nat',
      toports  => '47443',
    }
    firewall { '80 OUTPUT REDIRECT TO 47080':
      ensure   => 'present',
      chain    => 'OUTPUT',
      dport    => '80',
      jump     => 'REDIRECT',
      outiface => 'lo',
      proto    => 'tcp',
      table    => 'nat',
      toports  => '47080',
    }
  }

}
