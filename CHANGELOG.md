# Change log

All notable changes to this project will be documented in this file. The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org).

## [v2.2.0](https://github.com/treydock/puppet-module-gpfs/tree/v2.2.0) (2022-09-12)

[Full Changelog](https://github.com/treydock/puppet-module-gpfs/compare/v2.1.1...v2.2.0)

### Added

- Add gpfs::client::manage\_service\_files parameter [\#25](https://github.com/treydock/puppet-module-gpfs/pull/25) ([treydock](https://github.com/treydock))

## [v2.1.1](https://github.com/treydock/puppet-module-gpfs/tree/v2.1.1) (2022-07-06)

[Full Changelog](https://github.com/treydock/puppet-module-gpfs/compare/v2.1.0...v2.1.1)

### Fixed

- Fix handling of ensure present when fileset is unlinked [\#24](https://github.com/treydock/puppet-module-gpfs/pull/24) ([treydock](https://github.com/treydock))

## [v2.1.0](https://github.com/treydock/puppet-module-gpfs/tree/v2.1.0) (2021-10-04)

[Full Changelog](https://github.com/treydock/puppet-module-gpfs/compare/v2.0.0...v2.1.0)

### Added

- Update support stdlib, logrotate and sudo dependencies [\#23](https://github.com/treydock/puppet-module-gpfs/pull/23) ([treydock](https://github.com/treydock))

## [v2.0.0](https://github.com/treydock/puppet-module-gpfs/tree/v2.0.0) (2021-09-01)

[Full Changelog](https://github.com/treydock/puppet-module-gpfs/compare/v1.0.0...v2.0.0)

### Changed

- Remove new\_statefile property from gpfs\_fileset [\#21](https://github.com/treydock/puppet-module-gpfs/pull/21) ([treydock](https://github.com/treydock))
- BREAKING: Change how permissions are defined and enforced [\#20](https://github.com/treydock/puppet-module-gpfs/pull/20) ([treydock](https://github.com/treydock))

### Fixed

- Fix permissions updates and rest\_v2 provider [\#22](https://github.com/treydock/puppet-module-gpfs/pull/22) ([treydock](https://github.com/treydock))

## [v1.0.0](https://github.com/treydock/puppet-module-gpfs/tree/v1.0.0) (2021-07-02)

[Full Changelog](https://github.com/treydock/puppet-module-gpfs/compare/v0.8.0...v1.0.0)

### Changed

- Changes to Puppet and OS support \(read description\) [\#19](https://github.com/treydock/puppet-module-gpfs/pull/19) ([treydock](https://github.com/treydock))

## [v0.8.0](https://github.com/treydock/puppet-module-gpfs/tree/v0.8.0) (2020-10-03)

[Full Changelog](https://github.com/treydock/puppet-module-gpfs/compare/v0.7.0...v0.8.0)

### Added

- Better handling of unlinked filesets or changing junction path [\#17](https://github.com/treydock/puppet-module-gpfs/pull/17) ([treydock](https://github.com/treydock))

### Fixed

- Ensure missing user or group does not break prefetch [\#18](https://github.com/treydock/puppet-module-gpfs/pull/18) ([treydock](https://github.com/treydock))

## [v0.7.0](https://github.com/treydock/puppet-module-gpfs/tree/v0.7.0) (2020-04-17)

[Full Changelog](https://github.com/treydock/puppet-module-gpfs/compare/v0.6.0...v0.7.0)

### Added

- Disable GPFS GUI updating iptables [\#16](https://github.com/treydock/puppet-module-gpfs/pull/16) ([treydock](https://github.com/treydock))

## [v0.6.0](https://github.com/treydock/puppet-module-gpfs/tree/v0.6.0) (2020-04-17)

[Full Changelog](https://github.com/treydock/puppet-module-gpfs/compare/v0.5.0...v0.6.0)

### Added

- Add firewall\_https\_only to gpfs::gui class and allow firewall\_source to be false [\#15](https://github.com/treydock/puppet-module-gpfs/pull/15) ([treydock](https://github.com/treydock))
- Add gpfs::gui::manage\_services and gpfs::gui::manage\_initgui [\#14](https://github.com/treydock/puppet-module-gpfs/pull/14) ([treydock](https://github.com/treydock))

## [v0.5.0](https://github.com/treydock/puppet-module-gpfs/tree/v0.5.0) (2020-03-22)

[Full Changelog](https://github.com/treydock/puppet-module-gpfs/compare/v0.4.1...v0.5.0)

### Added

- Add inode\_tolerance parameter to gpfs\_fileset type [\#13](https://github.com/treydock/puppet-module-gpfs/pull/13) ([treydock](https://github.com/treydock))

## [v0.4.1](https://github.com/treydock/puppet-module-gpfs/tree/v0.4.1) (2020-03-20)

[Full Changelog](https://github.com/treydock/puppet-module-gpfs/compare/v0.4.0...v0.4.1)

### Fixed

- Increase inode tolerance [\#12](https://github.com/treydock/puppet-module-gpfs/pull/12) ([treydock](https://github.com/treydock))

## [v0.4.0](https://github.com/treydock/puppet-module-gpfs/tree/v0.4.0) (2020-03-20)

[Full Changelog](https://github.com/treydock/puppet-module-gpfs/compare/v0.3.1...v0.4.0)

### Changed

- Allow non-nsd to manage filesets [\#11](https://github.com/treydock/puppet-module-gpfs/pull/11) ([treydock](https://github.com/treydock))

## [v0.3.1](https://github.com/treydock/puppet-module-gpfs/tree/v0.3.1) (2020-01-24)

[Full Changelog](https://github.com/treydock/puppet-module-gpfs/compare/v0.3.0...v0.3.1)

### Fixed

- Fix duplicate resource errors [\#10](https://github.com/treydock/puppet-module-gpfs/pull/10) ([treydock](https://github.com/treydock))

## [v0.3.0](https://github.com/treydock/puppet-module-gpfs/tree/v0.3.0) (2020-01-23)

[Full Changelog](https://github.com/treydock/puppet-module-gpfs/compare/v0.2.2...v0.3.0)

### Added

- Allow clients to have PATH set [\#9](https://github.com/treydock/puppet-module-gpfs/pull/9) ([treydock](https://github.com/treydock))

## [v0.2.2](https://github.com/treydock/puppet-module-gpfs/tree/v0.2.2) (2019-12-16)

[Full Changelog](https://github.com/treydock/puppet-module-gpfs/compare/v0.2.1...v0.2.2)

### Fixed

- Better hacks on systemd enable [\#8](https://github.com/treydock/puppet-module-gpfs/pull/8) ([treydock](https://github.com/treydock))

## [v0.2.1](https://github.com/treydock/puppet-module-gpfs/tree/v0.2.1) (2019-12-16)

[Full Changelog](https://github.com/treydock/puppet-module-gpfs/compare/v0.2.0...v0.2.1)

### Fixed

- Fix systemd unit file to work with GPFS 5 [\#7](https://github.com/treydock/puppet-module-gpfs/pull/7) ([treydock](https://github.com/treydock))

## [v0.2.0](https://github.com/treydock/puppet-module-gpfs/tree/v0.2.0) (2019-12-12)

[Full Changelog](https://github.com/treydock/puppet-module-gpfs/compare/v0.1.4...v0.2.0)

### Added

- Allow limiting fileset management to specific filesystems [\#5](https://github.com/treydock/puppet-module-gpfs/pull/5) ([treydock](https://github.com/treydock))

## [v0.1.4](https://github.com/treydock/puppet-module-gpfs/tree/v0.1.4) (2019-10-11)

[Full Changelog](https://github.com/treydock/puppet-module-gpfs/compare/v0.1.3...v0.1.4)

### Fixed

- Support decreasing max inodes for a fileset [\#4](https://github.com/treydock/puppet-module-gpfs/pull/4) ([treydock](https://github.com/treydock))

## [v0.1.3](https://github.com/treydock/puppet-module-gpfs/tree/v0.1.3) (2019-08-20)

[Full Changelog](https://github.com/treydock/puppet-module-gpfs/compare/v0.1.2...v0.1.3)

### Fixed

- Fix README [\#3](https://github.com/treydock/puppet-module-gpfs/pull/3) ([treydock](https://github.com/treydock))

## [v0.1.2](https://github.com/treydock/puppet-module-gpfs/tree/v0.1.2) (2019-08-14)

[Full Changelog](https://github.com/treydock/puppet-module-gpfs/compare/v0.1.1...v0.1.2)

### Fixed

- Suppress diff of RKM.conf [\#2](https://github.com/treydock/puppet-module-gpfs/pull/2) ([treydock](https://github.com/treydock))

## [v0.1.1](https://github.com/treydock/puppet-module-gpfs/tree/v0.1.1) (2019-08-14)

[Full Changelog](https://github.com/treydock/puppet-module-gpfs/compare/v0.1.0...v0.1.1)

### Fixed

- Remove complicated template header [\#1](https://github.com/treydock/puppet-module-gpfs/pull/1) ([treydock](https://github.com/treydock))

## [v0.1.0](https://github.com/treydock/puppet-module-gpfs/tree/v0.1.0) (2019-08-14)

[Full Changelog](https://github.com/treydock/puppet-module-gpfs/compare/7ab87d965c0f5236440306170ba142c57fd1482e...v0.1.0)



\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
