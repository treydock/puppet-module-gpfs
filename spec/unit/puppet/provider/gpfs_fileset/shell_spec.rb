require 'spec_helper'

describe Puppet::Type.type(:gpfs_fileset).provider(:shell) do
  before(:each) do
    @provider = described_class
    @type = Puppet::Type.type(:gpfs_fileset)
    @resource = @type.new({
      :name => 'test1',
      :filesystem => 'test',
      :path => '/fs/test/test1',
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

  let(:mmlsfileset_header) do
    "mmlsfileset::HEADER:version:reserved:reserved:filesystemName:filesetName:id:rootInode:status:path:parentId:created:inodes:dataInKB:comment:filesetMode:afmTarget:afmState:afmMode:afmFileLookupRefreshInterval:afmFileOpenRefreshInterval:afmDirLookupRefreshInterval:afmDirOpenRefreshInterval:afmAsyncDelay:afmNeedsRecovery:afmExpirationTimeout:afmRPO:afmLastPSnapId:inodeSpace:isInodeSpaceOwner:maxInodes:allocInodes:inodeSpaceMask:afmShowHomeSnapshots:afmNumReadThreads:reserved:afmReadBufferSize:afmWriteBufferSize:afmReadSparseThreshold:afmParallelReadChunkSize:afmParallelReadThreshold:snapId:afmNumFlushThreads:afmPrefetchThreshold:afmEnableAutoEviction:permChangeFlag:afmParallelWriteThreshold:freeInodes:afmNeedsResync:afmParallelWriteChunkSize:afmNumWriteThreads:afmPrimaryID:afmDRState:afmAssociatedPrimaryId:afmDIO"
  end

  let(:mmlsfileset_output) do
    "#{mmlsfileset_header}
mmlsfileset::0:1:::test:root:0:3:Linked:%2Ffs%2Ftest:--:Mon Aug 14 16%3A08%3A03 2017:-:-:root fileset:off:-:-:-:-:-:-:-:-:-:-:-:-:0:1:65792:65792:14336:-:-:-:-:-:-:-:-:0:-:-:-:chmodAndSetacl:-:61784:-:-:-:-:-:-:-:
mmlsfileset::0:1:::test:test3:1:131075:Linked:%2Ffs%2Ftest%2Ftest3:0:Thu Aug 24 15%3A47%3A04 2017:-:-::off:-:-:-:-:-:-:-:-:-:-:-:-:1:1:2000000:1000000:14336:-:-:-:-:-:-:-:-:0:-:-:-:chmodAndSetacl:-:999999:-:-:-:-:-:-:-:
"
  end

  let(:all_filesets) do
    [
      {:ensure => :present, :name => 'test/root', :fileset => 'root', :filesystem => 'test', :path => '/fs/test',
       :max_num_inodes => 65792, :alloc_inodes => 65792, :owner => nil},
      {:ensure => :present, :name => 'test/test3', :fileset => 'test3', :filesystem => 'test', :path => '/fs/test/test3',
       :max_num_inodes => 2000000, :alloc_inodes => 1000000, :owner => nil},
    ]
  end

  describe 'self.instances' do
    it 'should create instances' do
      allow(@provider).to receive(:mmlsfs).with('all', '-T', '-Y').and_return(mmlsfs_output)
      allow(@provider).to receive(:mmlsfileset).with('test', '-Y').and_return(mmlsfileset_output)
      #allow(@provider).to receive(:mmclidecode).with('%2Ffs%2Ftest%2Ftest3').and_return('/fs/test/test3')
      expect(@provider.instances.length).to eq(2)
    end

    it 'should create no instance when no filesets returned' do
      allow(@provider).to receive(:mmlsfs).with('all', '-T', '-Y').and_return(mmlsfs_output)
      allow(@provider).to receive(:mmlsfileset).with('test', '-Y').and_return(mmlsfileset_header)
      expect(@provider.instances.length).to be_zero
    end

    it 'should create no instance when no filesystems returned' do
      allow(@provider).to receive(:mmlsfs).with('all', '-T', '-Y').and_return(mmlsfs_header)
      expect(@provider).not_to receive(:mmlsfileset)
      expect(@provider.instances.length).to be_zero
    end

    it 'should return the resource for a fileset' do
      allow(@provider).to receive(:mmlsfs).with('all', '-T', '-Y').and_return(mmlsfs_output)
      allow(@provider).to receive(:mmlsfileset).with('test', '-Y').and_return(mmlsfileset_output)
      #allow(@provider).to receive(:mmclidecode).with('%2Ffs%2Ftest%2Ftest3').and_return('/fs/test/test3')
      expect(@provider.instances[1].instance_variable_get("@property_hash")).to eq(all_filesets[1])
    end
  end

  describe 'self.prefetch' do
    let(:instances) do
      all_filesets.map { |f| @provider.new(f) }
    end
    let(:resources) do
      all_filesets.each_with_object({}) do |f, h|
        h[f[:name]] = @type.new(f.reject {|k,v| v.nil?})
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
    it 'should create and link a fileset' do
      expect(@resource.provider).to receive(:mmcrfileset).with(['test', 'test1', '--inode-space', 'new'])
      expect(@resource.provider).to receive(:mmlinkfileset).with(['test', 'test1', '-J', '/fs/test/test1'])
      @resource.provider.create
      property_hash = @resource.provider.instance_variable_get("@property_hash")
      expect(property_hash[:ensure]).to eq(:present)
    end

    #it 'should error if not path specified' do
    #  @resource.delete(:path)
    #  expect {
    #    @resource.provider.create
    #  }.to raise_error(Puppet::Error, /Path is mandatory/)
    #end
  end

  describe 'destroy' do
    it 'should unlink and delete a fileset' do
      expect(@resource.provider).to receive(:mmunlinkfileset).with(['test', 'test1'])
      expect(@resource.provider).to receive(:mmdelfileset).with(['test', 'test1'])
      @resource.provider.destroy
      property_hash = @resource.provider.instance_variable_get("@property_hash")
      expect(property_hash).to eq({})
    end
  end

  describe 'flush' do
    it 'should modify a fileset' do
      expect(@resource.provider).to receive(:mmchfileset).with(['test', 'test1', '--inode-limit', 5000])
      @resource.provider.max_num_inodes = 5000
      @resource.provider.flush
    end
  end

end
