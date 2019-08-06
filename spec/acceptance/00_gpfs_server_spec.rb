require 'spec_helper_acceptance'

describe 'gpfs::server class:' do
  context 'default parameters' do
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
      class { 'gpfs::server': }
      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe package('gpfs.base') do
      it { is_expected.to be_installed }
    end

    # describe service('gpfs') do
    #  it { should be_enabled }
    #  it { should be_running }
    # end
  end

  context 'setup base filesystem' do
    it 'builds gplbin' do
      pp = <<-EOS
      package { ['kernel-headers', 'gcc-c++']: ensure => 'present' }
      EOS
      apply_manifest(pp, catch_failures: true)
      shell 'mmbuildgpl', environment: { 'LINUX_DISTRIBUTION' => 'REDHAT_AS_LINUX' }
    end

    it 'setups test filesystem' do
      lsblk = shell('lsblk -o NAME --raw')
      disk = 'sdb'
      disks = lsblk.stdout.split("\n")
      disks.each do |line|
        next unless line =~ %r{^sd[ab]$}
        unless disks.include?("#{line}2")
          disk = line
          break
        end
      end
      pp = <<-EOS
      sshkey { "${::fqdn}_rsa":
        ensure       => present,
        host_aliases => [$::fqdn, $::hostname, $::ipaddress],
        type         => 'rsa',
        key          => $::sshrsakey,
      }
      exec { "ssh-keygen root":
        path    => '/usr/bin:/bin:/usr/sbin:/sbin',
        command => "ssh-keygen -q -t rsa -C root -N '' -f /root/.ssh/id_rsa",
        creates => ['/root/.ssh/id_rsa', '/root/.ssh/id_rsa.pub'],
      }
      file { '/tmp/test.lst':
        ensure => 'file',
        content => "
%nsd: device=#{disk}
nsd=#{disk}
servers=$::hostname
usage=dataAndMetadata
        "
      }
      EOS
      apply_manifest(pp, catch_failures: true)
      shell 'cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys'
      # shell "mmcrcluster -N #{fact('hostname')}:quorum:manager -C test -U #{fact('domain')}"
      mmlsfs = shell('mmlsfs test', accept_all_exit_codes: true)
      if mmlsfs.exit_code == 0
        skip('Filesystem already exists')
      end
      mmlscluster = shell('mmlscluster -Y | grep test', accept_all_exit_codes: true)
      if mmlscluster.exit_code != 0
        shell "mmcrcluster -N #{fact('hostname')}:quorum -C test -U #{fact('domain')}"
      end
      mmlslicense = shell("mmlslicense -Y | grep 'server:server'", accept_all_exit_codes: true)
      if mmlslicense.exit_code != 0
        shell "mmchlicense server --accept -N #{fact('hostname')}"
      end
      # stanza =<<-EOS
      # %nsd: device=loop0
      # nsd=loop0
      # servers=#{fact('hostname')}
      # usage=dataAndMetadata
      # EOS
      # create_remote_file(hosts, '/tmp/test.lst', stanza)
      mmlsnsd = shell("mmlsnsd -d #{disk} | grep #{fact('hostname')}", accept_all_exit_codes: true)
      if mmlsnsd.exit_code != 0
        shell 'mmcrnsd -F /tmp/test.lst'
      end
      mmlsfs = shell('mmlsfs test', accept_all_exit_codes: true)
      if mmlsfs.exit_code != 0
        shell('mmstartup')
        wait = true
        count = 0
        # wait for mmgetstate to be active
        # timeout after 120 seconds
        while wait
          mmgetstate = shell('mmgetstate')
          if mmgetstate.stdout =~ %r{active}
            wait = false
            break
          end
          count += 1
          if count > 12
            wait = false
          else
            sleep(10)
          end
        end
        shell 'mmcrfs test -F /tmp/test.lst -T /fs/test -A yes -n 1 -Q yes --perfileset-quota'
        # shell 'mmchfs test --perfileset-quota'
        shell 'mmcheckquota test'
      end
      shell 'mmmount all'
    end
  end
end
