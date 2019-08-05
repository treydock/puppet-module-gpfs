# Private class.
class gpfs::params {

  case $::osfamily {
    'RedHat': {
      $client_packages = []
      $server_packages = []
      $packages = [
        'gpfs.adv',
        'gpfs.base',
        'gpfs.crypto',
        'gpfs.docs',
        'gpfs.ext',
        'gpfs.gpl',
        "gpfs.gplbin-${::kernelrelease}",
        'gpfs.gskit',
        'gpfs.msg.en_US',
      ]
      $gui_packages = [
        'gpfs.gui',
      ]
      $ces_packages = [
        'gpfs.java',
        'gpfs.smb',
        'nfs-ganesha',
        'nfs-ganesha-gpfs',
        'nfs-ganesha-utils',
      ]
    }

    default: {
      fail("Unsupported osfamily: ${::osfamily}, module ${module_name} only support osfamily RedHat")
    }
  }

}
