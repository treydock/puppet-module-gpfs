require 'spec_helper'

describe 'gpfs::gui' do
  on_supported_os(supported_os: [
                    {
                      'operatingsystem' => 'RedHat',
                      'operatingsystemrelease' => ['7'],
                    },
                  ]).each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to create_class('gpfs::gui') }

      it { is_expected.to contain_class('gpfs').that_comes_before('Class[gpfs::gui::install]') }
      it { is_expected.to contain_class('gpfs::gui::install').that_comes_before('Class[gpfs::gui::config]') }
      it { is_expected.to contain_class('gpfs::gui::config').that_comes_before('Class[gpfs::gui::service]') }
      it { is_expected.to contain_class('gpfs::gui::service') }
    end # end context
  end # end on_supported_os loop
end # end describe
