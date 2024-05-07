# frozen_string_literal: true

require 'spec_helper'

describe 'gpfs::gui' do
  on_supported_os(supported_os: [
                    {
                      'operatingsystem' => 'RedHat',
                      'operatingsystemrelease' => ['7']
                    }
                  ]).each do |os, facts|
    context "when #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to create_class('gpfs::gui') }

      it { is_expected.to contain_class('gpfs').that_comes_before('Class[gpfs::gui::install]') }
      it { is_expected.to contain_class('gpfs::gui::install').that_comes_before('Class[gpfs::gui::config]') }
      it { is_expected.to contain_class('gpfs::gui::config').that_comes_before('Class[gpfs::gui::service]') }
      it { is_expected.to contain_class('gpfs::gui::service') }

      context 'when firewall_source is false' do
        let(:params) { { firewall_source: false } }

        it { is_expected.not_to contain_firewall('47443 *:47443') }
      end
    end
  end
end
