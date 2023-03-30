# frozen_string_literal: true

require 'spec_helper'

describe Puppet::Type.type(:gpfs_fileset_quota).provider(:shell) do
  let(:type) do
    Puppet::Type.type(:gpfs_fileset_quota)
  end
  let(:resource) do
    type.new(name: 'test1',
             filesystem: 'test',
             provider: 'shell')
  end

  let(:mmlsfs_header) do
    'mmlsfs::HEADER:version:reserved:reserved:deviceName:fieldName:data:remarks:'
  end

  let(:mmlsfs_output) do
    "#{mmlsfs_header}
mmlsfs::0:1:::test:defaultMountPoint:%2Ffs%2Ftest::"
  end

  let(:mmrepquota_output) do
    my_fixture_read('mmrepquota_output.out')
  end

  let(:all_quotas) do
    [
      { ensure: :present, name: 'test/root/usr/root', fileset: 'root', filesystem: 'test', object_name: 'root', type: :usr,
        block_soft_limit: '0', block_hard_limit: '0', files_soft_limit: 0, files_hard_limit: 0 },
      { ensure: :present, name: 'test/qtest1/usr/root', fileset: 'qtest1', filesystem: 'test', object_name: 'root', type: :usr,
        block_soft_limit: '0', block_hard_limit: '0', files_soft_limit: 0, files_hard_limit: 0 },
      { ensure: :present, name: 'test/test3/usr/root', fileset: 'test3', filesystem: 'test', object_name: 'root', type: :usr,
        block_soft_limit: '0', block_hard_limit: '0', files_soft_limit: 0, files_hard_limit: 0 },
      { ensure: :present, name: 'test/root/grp/root', fileset: 'root', filesystem: 'test', object_name: 'root', type: :grp,
        block_soft_limit: '0', block_hard_limit: '0', files_soft_limit: 0, files_hard_limit: 0 },
      { ensure: :present, name: 'test/qtest1/grp/root', fileset: 'qtest1', filesystem: 'test', object_name: 'root', type: :grp,
        block_soft_limit: '0', block_hard_limit: '0', files_soft_limit: 0, files_hard_limit: 0 },
      { ensure: :present, name: 'test/test3/grp/root', fileset: 'test3', filesystem: 'test', object_name: 'root', type: :grp,
        block_soft_limit: '0', block_hard_limit: '0', files_soft_limit: 0, files_hard_limit: 0 },
      { ensure: :present, name: 'test/root/fileset/root', fileset: 'root', filesystem: 'test', object_name: 'root', type: :fileset,
        block_soft_limit: '0', block_hard_limit: '0', files_soft_limit: 0, files_hard_limit: 0 },
      { ensure: :present, name: 'test/test3/fileset/test3', fileset: 'test3', filesystem: 'test', object_name: 'test3', type: :fileset,
        block_soft_limit: '0', block_hard_limit: '0', files_soft_limit: 0, files_hard_limit: 0 },
      { ensure: :present, name: 'test/qtest1/fileset/qtest1', fileset: 'qtest1', filesystem: 'test', object_name: 'qtest1', type: :fileset,
        block_soft_limit: '1T', block_hard_limit: '1T', files_soft_limit: 400_000, files_hard_limit: 400_000 }
    ]
  end

  describe 'self.instances' do
    it 'creates instances' do
      allow(described_class).to receive(:mmlsfs).with('all', '-T', '-Y').and_return(mmlsfs_output)
      allow(described_class).to receive(:mmrepquota).with('-Y', 'test').and_return(mmrepquota_output)
      expect(described_class.instances.length).to eq(9)
    end

    it 'creates no instance when no filesystems returned' do
      allow(described_class).to receive(:mmlsfs).with('all', '-T', '-Y').and_return(mmlsfs_header)
      expect(described_class).not_to receive(:mmrepquota)
      expect(described_class.instances.length).to be_zero
    end

    it 'returns the resource for a quota' do
      allow(described_class).to receive(:mmlsfs).with('all', '-T', '-Y').and_return(mmlsfs_output)
      allow(described_class).to receive(:mmrepquota).with('-Y', 'test').and_return(mmrepquota_output)
      expect(described_class.instances[0].instance_variable_get('@property_hash')).to eq(all_quotas[0])
      expect(described_class.instances[7].instance_variable_get('@property_hash')).to eq(all_quotas[7])
    end
  end

  describe 'self.prefetch' do
    let(:instances) do
      all_quotas.map { |f| described_class.new(f) }
    end
    let(:resources) do
      all_quotas.each_with_object({}) do |f, h|
        h[f[:name]] = type.new(f)
      end
    end

    before(:each) do
      allow(described_class).to receive(:instances).and_return(instances)
    end

    it 'prefetches' do
      resources.each_key do |r|
        expect(resources[r]).to receive(:provider=).with(described_class)
      end
      described_class.prefetch(resources)
    end
  end

  describe 'create' do
    it 'sets quota' do
      resource = type.new(name: 'test1',
                          filesystem: 'test',
                          block_soft_limit: '1T',
                          block_hard_limit: '1T',
                          files_soft_limit: 400_000,
                          files_hard_limit: 400_000,
                          provider: 'shell')
      expect(resource.provider).to receive(:mmsetquota).with(['test:test1', '--block', '1073741824K:1073741824K', '--files', '400000:400000'])
      resource.provider.create
      property_hash = resource.provider.instance_variable_get('@property_hash')
      expect(property_hash[:ensure]).to eq(:present)
    end
  end

  describe 'destroy' do
    it 'unsets quota' do
      expect(resource.provider).to receive(:mmsetquota).with(['test:test1', '--block', '0:0', '--files', '0:0'])
      resource.provider.destroy
      property_hash = resource.provider.instance_variable_get('@property_hash')
      expect(property_hash).to eq({})
    end
  end

  describe 'flush' do
    it 'modifies quota block limits' do
      expect(resource.provider).to receive(:mmsetquota).with(['test:test1', '--block', '1073741824K:1073741824K'])
      resource.provider.block_soft_limit = '1T'
      resource.provider.block_hard_limit = '1T'
      resource.provider.flush
    end
  end

  describe 'human_readable_kilobytes' do
    it 'handles 500G' do
      expect(resource.provider.class.human_readable_kilobytes(524_288_000)).to eq('500G')
    end

    it 'handles 5T' do
      expect(resource.provider.class.human_readable_kilobytes(5_368_709_120)).to eq('5T')
    end

    it 'handles 1.8T' do
      expect(resource.provider.class.human_readable_kilobytes(1_932_735_283)).to eq('1.8T')
    end

    it 'handles 1.8P' do
      expect(resource.provider.class.human_readable_kilobytes(1_932_735_283_200)).to eq('1.8P')
    end
  end
end
