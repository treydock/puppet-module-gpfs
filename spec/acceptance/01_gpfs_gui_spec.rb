require 'spec_helper_acceptance'

describe 'gpfs::gui class:' do
  context 'default parameters' do
    it 'should run successfully' do
      pp =<<-EOS
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
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe package('gpfs.gui') do
      it { should be_installed }
    end

    describe service('gpfsgui') do
      it { should be_enabled }
      it { should be_running }
    end
  end
end
