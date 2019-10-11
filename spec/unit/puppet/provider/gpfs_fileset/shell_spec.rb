require 'spec_helper'

describe Puppet::Type.type(:gpfs_fileset).provider(:shell) do
  let(:type) do
    Puppet::Type.type(:gpfs_fileset)
  end
  let(:resource) do
    type.new(name: 'test1',
             filesystem: 'test',
             path: '/fs/test/test1',
             provider: 'shell')
  end

  let(:mmlsfs_header) do
    'mmlsfs::HEADER:version:reserved:reserved:deviceName:fieldName:data:remarks:'
  end

  let(:mmlsfs_output) do
    "#{mmlsfs_header}
mmlsfs::0:1:::test:defaultMountPoint:%2Ffs%2Ftest::"
  end

  let(:mmlsfileset_header) do
    my_fixture_read('mmlsfileset_header.out')
  end

  let(:mmlsfileset_output) do
    "#{mmlsfileset_header}
    #{my_fixture_read('mmlsfileset_output.out')}
"
  end

  let(:all_filesets) do
    [
      { ensure: :present, name: 'test/root', fileset: 'root', filesystem: 'test', path: '/fs/test',
        max_num_inodes: 65_792, alloc_inodes: 65_792, owner: nil },
      { ensure: :present, name: 'test/test3', fileset: 'test3', filesystem: 'test', path: '/fs/test/test3',
        max_num_inodes: 2_000_000, alloc_inodes: 1_000_000, owner: nil },
    ]
  end

  describe 'self.instances' do
    it 'creates instances' do
      allow(described_class).to receive(:mmlsfs).with('all', '-T', '-Y').and_return(mmlsfs_output)
      allow(described_class).to receive(:mmlsfileset).with('test', '-Y').and_return(mmlsfileset_output)
      # allow(described_class).to receive(:mmclidecode).with('%2Ffs%2Ftest%2Ftest3').and_return('/fs/test/test3')
      expect(described_class.instances.length).to eq(2)
    end

    it 'creates no instance when no filesets returned' do
      allow(described_class).to receive(:mmlsfs).with('all', '-T', '-Y').and_return(mmlsfs_output)
      allow(described_class).to receive(:mmlsfileset).with('test', '-Y').and_return(mmlsfileset_header)
      expect(described_class.instances.length).to be_zero
    end

    it 'creates no instance when no filesystems returned' do
      allow(described_class).to receive(:mmlsfs).with('all', '-T', '-Y').and_return(mmlsfs_header)
      expect(described_class).not_to receive(:mmlsfileset)
      expect(described_class.instances.length).to be_zero
    end

    it 'returns the resource for a fileset' do
      allow(described_class).to receive(:mmlsfs).with('all', '-T', '-Y').and_return(mmlsfs_output)
      allow(described_class).to receive(:mmlsfileset).with('test', '-Y').and_return(mmlsfileset_output)
      # allow(described_class).to receive(:mmclidecode).with('%2Ffs%2Ftest%2Ftest3').and_return('/fs/test/test3')
      expect(described_class.instances[1].instance_variable_get('@property_hash')).to eq(all_filesets[1])
    end
  end

  describe 'self.prefetch' do
    let(:instances) do
      all_filesets.map { |f| described_class.new(f) }
    end
    let(:resources) do
      all_filesets.each_with_object({}) do |f, h|
        h[f[:name]] = type.new(f.reject { |_k, v| v.nil? })
      end
    end

    before(:each) do
      allow(described_class).to receive(:instances).and_return(instances)
    end

    it 'prefetches' do
      resources.keys.each do |r|
        expect(resources[r]).to receive(:provider=).with(described_class)
      end
      described_class.prefetch(resources)
    end
  end

  describe 'create' do
    it 'creates and link a fileset' do
      expect(resource.provider).to receive(:mmcrfileset).with(['test', 'test1', '--inode-space', 'new'])
      expect(resource.provider).to receive(:mmlinkfileset).with(['test', 'test1', '-J', '/fs/test/test1'])
      resource.provider.create
      property_hash = resource.provider.instance_variable_get('@property_hash')
      expect(property_hash[:ensure]).to eq(:present)
    end

    # it 'should error if not path specified' do
    #  resource.delete(:path)
    #  expect {
    #    resource.provider.create
    #  }.to raise_error(Puppet::Error, /Path is mandatory/)
    # end
  end

  describe 'destroy' do
    it 'unlinks and delete a fileset' do
      expect(resource.provider).to receive(:mmunlinkfileset).with(['test', 'test1'])
      expect(resource.provider).to receive(:mmdelfileset).with(['test', 'test1'])
      resource.provider.destroy
      property_hash = resource.provider.instance_variable_get('@property_hash')
      expect(property_hash).to eq({})
    end
  end

  describe 'flush' do
    it 'modifies a fileset' do
      expect(resource.provider).to receive(:mmchfileset).with(['test', 'test1', '--inode-limit', 5000])
      resource.provider.max_num_inodes = 5000
      resource.provider.flush
    end

    it 'decreases max inodes' do
      hash = resource.to_hash
      hash[:max_num_inodes] = 10_000
      resource.provider.instance_variable_set(:@property_hash, hash)
      expect(resource.provider).to receive(:mmchfileset).with(['test', 'test1', '--inode-limit', 5000])
      resource.provider.max_num_inodes = 5000
      resource.provider.flush
    end

    it 'cannot decreas alloc inodes' do
      hash = resource.to_hash
      hash[:alloc_inodes] = 10_000
      resource.provider.instance_variable_set(:@property_hash, hash)
      expect(resource.provider).not_to receive(:mmchfileset)
      expect(Puppet).to receive(:warning).with(%r{not permitted})
      resource.provider.alloc_inodes = 5000
      resource.provider.flush
    end
  end
end
