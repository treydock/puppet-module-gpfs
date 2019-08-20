# puppet-module-gpfs

[![Puppet Forge](http://img.shields.io/puppetforge/v/treydock/gpfs.svg)](https://forge.puppetlabs.com/treydock/gpfs)
[![Build Status](https://travis-ci.org/treydock/puppet-module-gpfs.png)](https://travis-ci.org/treydock/puppet-module-gpfs)

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with gpfs](#setup)
    * [What gpfs affects](#what-gpfs-affects)
    * [Setup requirements](#setup-requirements)
3. [Usage - Configuration options and additional functionality](#usage)
    * [Repo configuration](#repo-configuration)
    * [Clients](#clients)
    * [Filesets and Fileset Quotas](#filesets-and-fileset-quotas)
4. [Reference - Module reference](#reference)

## Description

This module will manage GPFS.

## Setup

### What gpfs affects

At this time the module is capable of installing GPFS packages and managing ISKLM configurations as well as SSH key authorization for client root logins.

### Setup Requirements

For systems with `yum` package manager using Puppet >= 6.0 there is a dependency on [puppetlabs/yumrepo_core](https://forge.puppet.com/puppetlabs/yumrepo_core).

## Usage

The class to include is based on a host's role:

* `gpfs::client` - GPFS clients
* `gpfs::server` - GPFS NSDs
* `gpfs::ces` - GPFS CES nodes
* `gpfs::gui` - GPFS GUI nodes

The class `gpfs` is not intended to be included directly but instead configured via Hiera

**NOTE:** All usage examples will assume you're using Hiera to define data.

### Repo configuration

The following is an example of configuring central YUM repository that hosts GPFS RPMs.

```yaml
gpfs::repo_baseurl: 'https://repo.example.com/gpfs/4/$releasever/'
```

### Clients

The following example will install packages necessary for GPFS client, configure SSH keys and enable ISKLM encryption.

```yaml
gpfs_keystore_password: >
    ENC[...]
gpfs::client::ssh_authorized_keys:
  'root@gpfs':
    key: 'AAAAB3Nza=='
gpfs::client::rkms:
  'ISKLM_srv':
    type: 'ISKLM'
    kmip_server_uris:
      - 'tls://isklm01:5696'
      - 'tls://isklm02:5696'
    key_store: '/var/mmfs/etc/RKMcerts/ISKLM.gpfs'
    key_store_source: 'puppet:///modules/profile/gpfs/ISKLM.gpfs'
    passphrase: "%{lookup('gpfs_keystore_password')}"
    client_cert_label: 'gpfs'
    tenant_name: 'GS_ISKLM'
```

### Filesets and Fileset Quotas

This module provides native types for managing GPFS filesets and GPFS quotas. Each defaults to the `shell` provider but there is also a `rest_v2` provider.

**NOTE**: The `rest_v2` provider is no longer tested or maintained
**NOTE**: The `gpfs_fileset_quota` type is capable of managing user and group quotas but only fileset quotas have been tested in production.

Create a fileset and fileset quota:

```puppet
gpfs_fileset { 'test':
  ensure => 'present',
  filesystem     => 'project',
  path           => '/gpfs/project/test',
  owner          => 'user1:group1',
  permissions    => '0770',
  max_num_inodes => 1000000,
  alloc_inodes   => 1000000,
}

gpfs_fileset_quota { 'test':
  filesystem       => 'project',
  block_soft_limit => '5T',
  block_hard_limit => '5T',
  files_soft_limit => 1000000,
  files_hard_limit => 1000000,
}
```

## Reference

[http://treydock.github.io/puppet-module-gpfs/](http://treydock.github.io/puppet-module-gpfs/)
