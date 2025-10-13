# frozen_string_literal: true

require 'spec_helper'

describe 'gpfs::client' do
  on_supported_os(supported_os: [
                    {
                      'operatingsystem' => 'RedHat',
                      'operatingsystemrelease' => ['8', '9'],
                    },
                  ]).each do |os, os_facts|
    context "when #{os}" do
      let(:kernel) do
        case os_facts[:os]['release']['major'].to_i
        when 9
          '5.10'
        when 8
          '4.11'
        end
      end
      let(:facts) { os_facts.merge!({ 'kernelrelease' => kernel }) }

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
      [].each do |param|
        context "with #{param} => 'foo'" do
          let(:params) { { param.to_sym => 'foo' } }

          it 'raises an error' do
            expect { is_expected.to compile }.to raise_error(%r{is not a boolean})
          end
        end
      end
    end
  end
end
