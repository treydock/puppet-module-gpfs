# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'gpfs_fileset_quota type:' do
  context 'when create quota' do
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
      gpfs_fileset { 'qtest1':
        filesystem      => 'test',
        owner           => 'root:root',
        permissions     => '1770',
        max_num_inodes  => 400000,
        alloc_inodes    => 400000,
      }
      gpfs_fileset_quota { 'qtest1':
        filesystem => 'test',
        block_soft_limit => '1G',
        block_hard_limit => '1G',
        files_soft_limit => 400000,
        files_hard_limit => 400000,
      }
      PP

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end
  end

  context 'when quota with decimal' do
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
      gpfs_fileset { 'qtest1':
        filesystem      => 'test',
        owner           => 'root:root',
        permissions     => '1770',
        max_num_inodes  => 400000,
        alloc_inodes    => 400000,
      }
      gpfs_fileset_quota { 'qtest1':
        filesystem => 'test',
        block_soft_limit => '1.5G',
        block_hard_limit => '1.5G',
        files_soft_limit => 400000,
        files_hard_limit => 400000,
      }
      PP

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end
  end

  context 'when modify quota' do
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
      gpfs_fileset { 'qtest1':
        filesystem      => 'test',
        owner           => 'root:root',
        permissions     => '1770',
        max_num_inodes  => 1000000,
        alloc_inodes    => 1000000,
      }
      gpfs_fileset_quota { 'qtest1':
        filesystem => 'test',
        block_soft_limit => '10G',
        block_hard_limit => '10G',
        files_soft_limit => 1000000,
        files_hard_limit => 1000000,
      }
      PP

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end
  end

  context 'when delete quota' do
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
      gpfs_fileset_quota { 'qtest1':
        ensure      => 'absent',
        filesystem  => 'test',
      }
      PP

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end
  end
end
