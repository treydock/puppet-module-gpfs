# @summary Manage GPFS GUI services
# @api private
class gpfs::gui::service {
  assert_private()

  if $gpfs::gui::manage_services {
    service { 'pmcollector':
      ensure     => 'running',
      enable     => true,
      hasstatus  => true,
      hasrestart => true,
      before     => Service['gpfsgui'],
    }

    service { 'gpfsgui':
      ensure     => 'running',
      enable     => true,
      hasstatus  => true,
      hasrestart => true,
    }

    if $gpfs::gui::manage_initgui {
      exec { '/usr/lpp/mmfs/gui/cli/initgui':
        path        => '/usr/bin:/bin:/usr/sbin:/sbin',
        command     => '/usr/lpp/mmfs/gui/cli/initgui && touch /var/lib/mmfs/initgui.done',
        refreshonly => true,
        creates     => '/var/lib/mmfs/initgui.done',
        onlyif      => [
          'test -f /var/mmfs/gen/mmsdrfs',
        ],
        require     => Service['gpfsgui'],
      }
    }
  }
}
