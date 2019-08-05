# Private class.
class gpfs::gui::service {
  assert_private()

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
