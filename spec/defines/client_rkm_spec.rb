require 'spec_helper'

describe 'gpfs::client::rkm' do
  on_supported_os(supported_os: [
                    {
                      'operatingsystem' => 'RedHat',
                      'operatingsystemrelease' => ['6', '7'],
                    },
                  ]).each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(concat_basedir: '/dne')
      end

      let :title do
        'ISKLM_srv'
      end

      let :params do
        {
          kmip_server_uris: ['tls://isklm01:5696', 'tls://isklm02:5696'],
          key_store_source: 'puppet:///some/path',
          passphrase: 'changeme',
          client_cert_label: 'test',
          tenant_name: 'tenant',
        }
      end

      it 'has valid config content' do
        verify_concat_fragment_exact_contents(catalogue, 'RKM.conf.ISKLM_srv', [
                                                'ISKLM_srv {',
                                                '  type = ISKLM',
                                                '  kmipServerUri = tls://isklm01:5696',
                                                '  kmipServerUri2 = tls://isklm02:5696',
                                                '  keyStore = /var/mmfs/etc/RKMcerts/ISKLM.proj2',
                                                '  passphrase = changeme',
                                                '  clientCertLabel = test',
                                                '  tenantName = tenant',
                                                '  connectionTimeout = 5',
                                                '  connectionAttempts = 3',
                                                '  retrySleep = 50000',
                                                '}',
                                              ])
      end

      it 'manages key store parent directory' do
        is_expected.to contain_file('/var/mmfs/etc/RKMcerts').with(ensure: 'directory',
                                                                   owner: 'root',
                                                                   group: 'root',
                                                                   mode: '0755')
      end

      it 'manages key store' do
        is_expected.to contain_file('/var/mmfs/etc/RKMcerts/ISKLM.proj2').with(ensure: 'file',
                                                                               owner: 'root',
                                                                               group: 'root',
                                                                               mode: '0600',
                                                                               source: 'puppet:///some/path')
      end
    end
  end
end
