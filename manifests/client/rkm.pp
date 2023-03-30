# @summary Manage GPFS client ISKLM configuration
#
# @param rkm_id
# @param type
# @param kmip_server_uris
# @param key_store
# @param key_store_source
# @param passphrase
# @param client_cert_label
# @param tenant_name
# @param connection_timeout
# @param connection_attempts
# @param retry_sleep
# @param order
define gpfs::client::rkm (
  String[1] $rkm_id = $name,
  String[1] $type = 'ISKLM',
  Array $kmip_server_uris     = [],
  Stdlib::Absolutepath $key_store = '/var/mmfs/etc/RKMcerts/ISKLM.proj2',
  Optional[String[1]] $key_store_source = undef,
  Optional[String[1]] $passphrase = undef,
  Optional[String[1]] $client_cert_label = undef,
  Optional[String[1]] $tenant_name = undef,
  String[1] $connection_timeout = '5',
  String[1] $connection_attempts = '3',
  String[1] $retry_sleep = '50000',
  String[1] $order = '10',
) {
  # Template uses:
  # - $rkm_id
  # - $kmip_server_uris
  # - $key_store
  # - $passphrase
  # - $client_cert_label
  # - $tenant_name
  # - $connection_timeout
  # - $connection_attempts
  # - $retry_sleep
  concat::fragment { "RKM.conf.${name}":
    target  => '/var/mmfs/etc/RKM.conf',
    content => template('gpfs/RKM.conf.erb'),
    order   => $order,
  }

  $_key_store_parent = dirname($key_store)
  if ! defined(File[$_key_store_parent]) {
    file { $_key_store_parent:
      ensure => 'directory',
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
    }
  }

  if ! defined(File[$key_store]) {
    file { $key_store:
      ensure => 'file',
      owner  => 'root',
      group  => 'root',
      mode   => '0600',
      source => $key_store_source,
    }
  }
}
