require 'spec_helper'

describe 'gpfs::server' do
  on_supported_os(supported_os: [
                    {
                      'operatingsystem' => 'RedHat',
                      'operatingsystemrelease' => ['6', '7'],
                    },
                  ]).each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to create_class('gpfs::server') }

      it { is_expected.to contain_class('gpfs').that_comes_before('Class[gpfs::server::install]') }
      it { is_expected.to contain_class('gpfs::server::install').that_comes_before('Class[gpfs::server::config]') }

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
