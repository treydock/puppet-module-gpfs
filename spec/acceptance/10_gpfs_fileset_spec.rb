# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'gpfs_fileset type:' do
  context 'when create fileset' do
    it 'runs successfully' do
      pp = <<-PP
      class { 'gpfs':
        packages => [
          'gpfs.adv',
          'gpfs.base',
          'gpfs.crypto',
          'gpfs.docs',
          'gpfs.ext',
          'gpfs.gpl',
          'gpfs.gskit',
          'gpfs.msg.en_US',
        ]
      }
      gpfs_fileset { 'test1':
        filesystem      => 'test',
        owner           => 'root:root',
        permissions     => '1770',
        max_num_inodes  => 400000,
        alloc_inodes    => 400000,
      }
      PP

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe file('/fs/test/test1') do
      it { is_expected.to be_directory }
      it { is_expected.to be_mounted.with(type: 'gpfs') }
      it { is_expected.to be_mode 1770 }
      it { is_expected.to be_owned_by 'root' }
      it { is_expected.to be_grouped_into 'root' }
    end
  end

  context 'when modify fileset max_num_inodes' do
    it 'runs successfully' do
      pp = <<-PP
      class { 'gpfs':
        packages => [
          'gpfs.adv',
          'gpfs.base',
          'gpfs.crypto',
          'gpfs.docs',
          'gpfs.ext',
          'gpfs.gpl',
          'gpfs.gskit',
          'gpfs.msg.en_US',
        ]
      }
      gpfs_fileset { 'test1':
        filesystem      => 'test',
        owner           => 'root:root',
        permissions     => '1770',
        max_num_inodes  => 1000000,
        alloc_inodes    => 1000000,
      }
      PP

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end
  end

  context 'when modify fileset owner' do
    it 'runs successfully' do
      pp = <<-PP
      class { 'gpfs':
        packages => [
          'gpfs.adv',
          'gpfs.base',
          'gpfs.crypto',
          'gpfs.docs',
          'gpfs.ext',
          'gpfs.gpl',
          'gpfs.gskit',
          'gpfs.msg.en_US',
        ]
      }
      gpfs_fileset { 'test1':
        filesystem      => 'test',
        owner           => 'adm:adm',
        permissions     => '1770',
        max_num_inodes  => 1000000,
        alloc_inodes    => 1000000,
      }
      PP

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe file('/fs/test/test1') do
      it { is_expected.to be_directory }
      it { is_expected.to be_mode 1770 }
      it { is_expected.to be_owned_by 'adm' }
      it { is_expected.to be_grouped_into 'adm' }
    end
  end

  context 'when decreasing alloc_inodes' do
    it 'runs successfully' do
      pp = <<-PP
      class { 'gpfs':
        packages => [
          'gpfs.adv',
          'gpfs.base',
          'gpfs.crypto',
          'gpfs.docs',
          'gpfs.ext',
          'gpfs.gpl',
          'gpfs.gskit',
          'gpfs.msg.en_US',
        ]
      }
      gpfs_fileset { 'test1':
        filesystem      => 'test',
        owner           => 'adm:adm',
        permissions     => '1770',
        max_num_inodes  => 800000,
        alloc_inodes    => 800000,
      }
      PP

      apply_manifest(pp, catch_failures: true)
    end
  end

  context 'when change fileset junction path' do
    it 'runs successfully' do
      pp = <<-PP
      class { 'gpfs':
        packages => [
          'gpfs.adv',
          'gpfs.base',
          'gpfs.crypto',
          'gpfs.docs',
          'gpfs.ext',
          'gpfs.gpl',
          'gpfs.gskit',
          'gpfs.msg.en_US',
        ]
      }
      gpfs_fileset { 'test1':
        filesystem      => 'test',
        path            => '/fs/test/test2',
        owner           => 'adm:adm',
        permissions     => '1770',
        max_num_inodes  => 800000,
        alloc_inodes    => 800000,
      }
      PP

      apply_manifest(pp, catch_failures: true)
    end

    describe file('/fs/test/test2') do
      it { is_expected.to be_directory }
      it { is_expected.to be_mounted.with(type: 'gpfs') }
      it { is_expected.to be_mode 1770 }
      it { is_expected.to be_owned_by 'root' }
      it { is_expected.to be_grouped_into 'root' }
    end
  end

  context 'when unlink fileset' do
    it 'runs successfully' do
      pp = <<-PP
      class { 'gpfs':
        packages => [
          'gpfs.adv',
          'gpfs.base',
          'gpfs.crypto',
          'gpfs.docs',
          'gpfs.ext',
          'gpfs.gpl',
          'gpfs.gskit',
          'gpfs.msg.en_US',
        ]
      }
      gpfs_fileset { 'test1':
        ensure          => 'unlinked',
        filesystem      => 'test',
        path            => '/fs/test/test2',
        owner           => 'adm:adm',
        permissions     => '1770',
        max_num_inodes  => 800000,
        alloc_inodes    => 800000,
      }
      PP

      apply_manifest(pp, catch_failures: true)
    end

    describe file('/fs/test/test2') do
      it { is_expected.not_to be_directory }
      it { is_expected.not_to be_mounted.with(type: 'gpfs') }
    end
  end

  context 'when delete fileset' do
    it 'runs successfully' do
      pp = <<-PP
      class { 'gpfs':
        packages => [
          'gpfs.adv',
          'gpfs.base',
          'gpfs.crypto',
          'gpfs.docs',
          'gpfs.ext',
          'gpfs.gpl',
          'gpfs.gskit',
          'gpfs.msg.en_US',
        ]
      }
      gpfs_fileset { 'test1':
        ensure      => 'absent',
        filesystem  => 'test',
      }
      file { '/fs/test/test2/.new_fileset':
        ensure => 'absent',
        before => Gpfs_fileset['test2'],
      }
      gpfs_fileset { 'test2':
        ensure      => 'absent',
        filesystem  => 'test',
      }
      PP

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end
  end
end
