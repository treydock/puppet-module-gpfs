require 'spec_helper_acceptance'

describe 'gpfs_fileset type:' do
  context 'create fileset' do
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
      class { 'gpfs::gui':
        manage_firewall => false,
      }
      gpfs_fileset { 'test1':
        filesystem      => 'test',
        owner           => 'root:root',
        permissions     => '1770',
        max_num_inodes  => 400000,
        alloc_inodes    => 400000,
      }
      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe file('/fs/test/test1') do
      it { is_expected.to be_directory }
      it { is_expected.to be_mode 1770 }
      it { is_expected.to be_owned_by 'root' }
      it { is_expected.to be_grouped_into 'root' }
    end
  end

  context 'modify fileset max_num_inodes' do
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
      class { 'gpfs::gui':
        manage_firewall => false,
      }
      gpfs_fileset { 'test1':
        filesystem      => 'test',
        owner           => 'root:root',
        permissions     => '1770',
        max_num_inodes  => 1000000,
        alloc_inodes    => 1000000,
      }
      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end
  end

  context 'modify fileset owner' do
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
      class { 'gpfs::gui':
        manage_firewall => false,
      }
      gpfs_fileset { 'test1':
        filesystem      => 'test',
        owner           => 'adm:adm',
        permissions     => '1770',
        max_num_inodes  => 1000000,
        alloc_inodes    => 1000000,
      }
      EOS

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

  context 'decreasing alloc_inodes' do
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
      class { 'gpfs::gui':
        manage_firewall => false,
      }
      gpfs_fileset { 'test1':
        filesystem      => 'test',
        owner           => 'adm:adm',
        permissions     => '1770',
        max_num_inodes  => 800000,
        alloc_inodes    => 800000,
      }
      EOS

      apply_manifest(pp, catch_failures: true)
    end
  end

  context 'create fileset with statefile' do
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
      class { 'gpfs::gui':
        manage_firewall => false,
      }
      gpfs_fileset { 'test2':
        filesystem      => 'test',
        owner           => 'root:root',
        permissions     => '1770',
        max_num_inodes  => 400000,
        alloc_inodes    => 400000,
        new_statefile   => '.new_fileset',
      }
      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe file('/fs/test/test2/.new_fileset') do
      it { is_expected.to be_file }
      it { is_expected.to be_mode 400 }
      it { is_expected.to be_owned_by 'root' }
      it { is_expected.to be_grouped_into 'root' }
    end
  end

  context 'delete fileset' do
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
      class { 'gpfs::gui':
        manage_firewall => false,
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
      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end
  end
end
