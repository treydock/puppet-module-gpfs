require 'spec_helper'

describe 'gpfs::client' do
  on_supported_os(supported_os: [
                    {
                      'operatingsystem' => 'RedHat',
                      'operatingsystemrelease' => ['6', '7'],
                    },
                  ]).each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      let(:kernel) do
        case facts[:operatingsystemmajrelease].to_i
        when 7
          '3.10.0-957.12.2.el7.x86_64'
        when 6
          '2.6.32-754.18.2.el6.x86_64'
        end
      end

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to create_class('gpfs::client') }

      it { is_expected.to contain_class('gpfs').that_comes_before('Class[gpfs::client::install]') }
      it { is_expected.to contain_class('gpfs::client::install').that_comes_before('Class[gpfs::client::config]') }
      it { is_expected.to contain_class('gpfs::client::config') }

      it { is_expected.to contain_package("gpfs.gplbin-#{kernel}").with_ensure('present') }

      context 'when server included' do
        let(:pre_condition) { 'include gpfs::server' }

        it { is_expected.to compile.with_all_deps }
      end

      # Test validate_bool parameters
      [
      ].each do |param|
        context "with #{param} => 'foo'" do
          let(:params) { { param.to_sym => 'foo' } }

          it 'raises an error' do
            expect { is_expected.to compile }.to raise_error(%r{is not a boolean})
          end
        end
      end
    end # end context
  end # end on_supported_os loop
end # end describe
