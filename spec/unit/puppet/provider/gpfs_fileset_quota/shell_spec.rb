require 'spec_helper'

describe Puppet::Type.type(:gpfs_fileset_quota).provider(:shell) do
  before(:each) do
    @provider = described_class
    @type = Puppet::Type.type(:gpfs_fileset_quota)
    @resource = @type.new({
      :name => 'test1',
      :filesystem => 'test',
      :provider => 'shell',
    })
  end

  let(:mmlsfs_header) do
    "mmlsfs::HEADER:version:reserved:reserved:deviceName:fieldName:data:remarks:"
  end

  let(:mmlsfs_output) do
    "#{mmlsfs_header}
mmlsfs::0:1:::test:defaultMountPoint:%2Ffs%2Ftest::"
  end

  let(:mmrepquota_output) do
    "mmrepquota::HEADER:version:reserved:reserved:filesystemName:quotaType:id:name:blockUsage:blockQuota:blockLimit:blockInDoubt:blockGrace:filesUsage:filesQuota:filesLimit:filesInDoubt:filesGrace:remarks:quota:defQuota:fid:filesetname:
mmrepquota::0:1:::test:USR:0:root:256:0:0:0:none:1:0:0:0:none:i:on:off:0:root:
mmrepquota::0:1:::test:USR:0:root:0:0:0:10240:none:1:0:0:39:none:i:on:off:2:qtest1:
mmrepquota::0:1:::test:USR:20821:tdockendorf:0:0:0:0:none:1:0:0:0:none:i:on:off:1:test3:
mmrepquota::0:1:::test:GRP:0:root:256:0:0:0:none:1:0:0:0:none:i:on:off:0:root:
mmrepquota::0:1:::test:GRP:0:root:0:0:0:10240:none:1:0:0:39:none:i:on:off:2:qtest1:
mmrepquota::0:1:::test:GRP:103:sysp:0:0:0:0:none:1:0:0:0:none:i:on:off:1:test3:
mmrepquota::0:1:::test:FILESET:0:root:256:0:0:0:none:1:0:0:0:none:i:on:off:::
mmrepquota::0:1:::test:FILESET:1:test3:0:0:0:0:none:1:0:0:0:none:N/A:on:off:::
mmrepquota::0:1:::test:FILESET:2:qtest1:0:1073741824:1073741824:0:none:1:400000:400000:0:none:e:on:off:::"
  end

  let(:all_quotas) do
    [
      {:ensure => :present, :name => 'test/root/usr/root', :fileset => 'root', :filesystem => 'test', :object_name => 'root', :type => :usr,
       :block_soft_limit => '0', :block_hard_limit => '0', :files_soft_limit => 0, :files_hard_limit => 0,
      },
      {:ensure => :present, :name => 'test/qtest1/usr/root', :fileset => 'qtest1', :filesystem => 'test', :object_name => 'root', :type => :usr,
       :block_soft_limit => '0', :block_hard_limit => '0', :files_soft_limit => 0, :files_hard_limit => 0,
      },
      {:ensure => :present, :name => 'test/test3/usr/root', :fileset => 'test3', :filesystem => 'test', :object_name => 'root', :type => :usr,
       :block_soft_limit => '0', :block_hard_limit => '0', :files_soft_limit => 0, :files_hard_limit => 0,
      },
      {:ensure => :present, :name => 'test/root/grp/root', :fileset => 'root', :filesystem => 'test', :object_name => 'root', :type => :grp,
       :block_soft_limit => '0', :block_hard_limit => '0', :files_soft_limit => 0, :files_hard_limit => 0,
      },
      {:ensure => :present, :name => 'test/qtest1/grp/root', :fileset => 'qtest1', :filesystem => 'test', :object_name => 'root', :type => :grp,
       :block_soft_limit => '0', :block_hard_limit => '0', :files_soft_limit => 0, :files_hard_limit => 0,
      },
      {:ensure => :present, :name => 'test/test3/grp/root', :fileset => 'test3', :filesystem => 'test', :object_name => 'root', :type => :grp,
       :block_soft_limit => '0', :block_hard_limit => '0', :files_soft_limit => 0, :files_hard_limit => 0,
      },
      {:ensure => :present, :name => 'test/root/fileset/root', :fileset => 'root', :filesystem => 'test', :object_name => 'root', :type => :fileset,
       :block_soft_limit => '0', :block_hard_limit => '0', :files_soft_limit => 0, :files_hard_limit => 0,
      },
      {:ensure => :present, :name => 'test/test3/fileset/test3', :fileset => 'test3', :filesystem => 'test', :object_name => 'test3', :type => :fileset,
       :block_soft_limit => '0', :block_hard_limit => '0', :files_soft_limit => 0, :files_hard_limit => 0,
      },
      {:ensure => :present, :name => 'test/qtest1/fileset/qtest1', :fileset => 'qtest1', :filesystem => 'test', :object_name => 'qtest1', :type => :fileset,
       :block_soft_limit => '1T', :block_hard_limit => '1T', :files_soft_limit => 400000, :files_hard_limit => 400000,
      },
    ]
  end

  describe 'self.instances' do
    it 'should create instances' do
      allow(@provider).to receive(:mmlsfs).with('all', '-T', '-Y').and_return(mmlsfs_output)
      allow(@provider).to receive(:mmrepquota).with('-Y', 'test').and_return(mmrepquota_output)
      expect(@provider.instances.length).to eq(9)
    end

    it 'should create no instance when no filesystems returned' do
      allow(@provider).to receive(:mmlsfs).with('all', '-T', '-Y').and_return(mmlsfs_header)
      expect(@provider).not_to receive(:mmrepquota)
      expect(@provider.instances.length).to be_zero
    end

    it 'should return the resource for a quota' do
      allow(@provider).to receive(:mmlsfs).with('all', '-T', '-Y').and_return(mmlsfs_output)
      allow(@provider).to receive(:mmrepquota).with('-Y', 'test').and_return(mmrepquota_output)
      expect(@provider.instances[0].instance_variable_get("@property_hash")).to eq(all_quotas[0])
      expect(@provider.instances[7].instance_variable_get("@property_hash")).to eq(all_quotas[7])
    end
  end

  describe 'self.prefetch' do
    let(:instances) do
      all_quotas.map { |f| @provider.new(f) }
    end
    let(:resources) do
      all_quotas.each_with_object({}) do |f, h|
        h[f[:name]] = @type.new(f)
      end
    end

    before(:each) do
      allow(@provider).to receive(:instances).and_return(instances)
    end

    it 'should prefetch' do
      resources.keys.each do |r|
        expect(resources[r]).to receive(:provider=).with(@provider)
      end
      @provider.prefetch(resources)
    end
  end

  describe 'create' do
    it 'should set quota' do
      @resource = @type.new({
        :name => 'test1',
        :filesystem => 'test',
        :block_soft_limit => '1T',
        :block_hard_limit => '1T',
        :files_soft_limit => 400000,
        :files_hard_limit => 400000,
        :provider => 'shell',
      })
      expect(@resource.provider).to receive(:mmsetquota).with(['test:test1', '--block', '1073741824K:1073741824K', '--files', '400000:400000'])
      @resource.provider.create
      property_hash = @resource.provider.instance_variable_get("@property_hash")
      expect(property_hash[:ensure]).to eq(:present)
    end
  end

  describe 'destroy' do
    it 'should unset quota' do
      expect(@resource.provider).to receive(:mmsetquota).with(['test:test1', '--block', '0:0', '--files', '0:0'])
      @resource.provider.destroy
      property_hash = @resource.provider.instance_variable_get("@property_hash")
      expect(property_hash).to eq({})
    end
  end

  describe 'flush' do
    it 'should modify quota block limits' do
      expect(@resource.provider).to receive(:mmsetquota).with(['test:test1', '--block', '1073741824K:1073741824K'])
      @resource.provider.block_soft_limit = '1T'
      @resource.provider.block_hard_limit = '1T'
      @resource.provider.flush
    end
  end

  describe 'human_readable_kilobytes' do
    it 'should handle 500G' do
      expect(@resource.provider.class.human_readable_kilobytes(524288000)).to eq('500G')
    end
    it 'should handle 5T' do
      expect(@resource.provider.class.human_readable_kilobytes(5368709120)).to eq('5T')
    end
    it 'should handle 1.8T' do
      expect(@resource.provider.class.human_readable_kilobytes(1932735283)).to eq('1.8T')
    end
  end

end
