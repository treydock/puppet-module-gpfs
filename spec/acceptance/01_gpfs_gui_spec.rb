# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'gpfs::gui class:' do
  before(:each) do
    skip('Skip GUI tests')
  end

  context 'with default parameters' do
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
      class { 'gpfs::gui':
        manage_firewall => false,
      }
      PP

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe package('gpfs.gui') do
      it { is_expected.to be_installed }
    end

    describe service('gpfsgui') do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end
  end
end
