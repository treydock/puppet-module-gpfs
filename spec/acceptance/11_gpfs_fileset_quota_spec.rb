require 'spec_helper_acceptance'

describe 'gpfs_fileset_quota type:' do
  context 'create quota' do
    it 'runs successfully' do
      pp = <<-EOS
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
      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end
  end

  context 'quota with decimal' do
    it 'runs successfully' do
      pp = <<-EOS
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
      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end
  end

  context 'modify quota' do
    it 'runs successfully' do
      pp = <<-EOS
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
      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end
  end

  context 'delete quota' do
    it 'runs successfully' do
      pp = <<-EOS
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
      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end
  end
end
