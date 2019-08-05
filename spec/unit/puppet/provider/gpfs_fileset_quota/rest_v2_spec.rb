require 'spec_helper'

describe Puppet::Type.type(:gpfs_fileset_quota).provider(:rest_v2) do
  before(:each) do
    @provider = described_class
    @type = Puppet::Type.type(:gpfs_fileset_quota)
    @resource = @type.new({
      :name => 'test',
      :filesystem => 'project',
      :provider => 'rest_v2',
    })
  end

  let(:all_quotas_data) do
    {
      "quotas" => [
        {"filesetName" => "test1", "filesystemName" => "project", "quotaType" => 'USR', "objectName" => "test1",
         "blockLimit"  => 1048576, "blockQuota" => 1048576, "filesLimit" => 1000000, "filesQuota" => 1000000,
        },
        {"filesetName" => "test2", "filesystemName" => "project", "quotaType" => 'FILESET', "objectName" => "test2",
         "blockLimit"  => 2147483648, "blockQuota" => 2147483648, "filesLimit" => 1000000, "filesQuota" => 1000000,
        },
        {"filesetName" => "test1", "filesystemName" => "scratch", "quotaType" => 'FILESET', "objectName" => "test1"},
      ],
      "status" => {
        "code" => 200,
        "message" => "The request finished successfully",
      },
    }
  end

  let(:all_quotas) do
    [
      {:ensure => :present, :name => 'project/test1/test1', :fileset => 'test1', :filesystem => 'project', :object_name => 'test1', :type => 'usr',
       :block_soft_limit => '1G', :block_hard_limit => '1G', :files_soft_limit => 1000000, :files_hard_limit => 1000000,
      },
      {:ensure => :present, :name => 'project/test2/test1', :fileset => 'test2', :filesystem => 'project', :object_name => 'test2', :type => 'fileset',
       :block_soft_limit => '2T', :block_hard_limit => '2T', :files_soft_limit => 1000000, :files_hard_limit => 1000000,
      },
      {:ensure => :present, :name => 'scratch/test1/test1', :fileset => 'test1', :filesystem => 'scratch', :object_name => 'test1', :type => 'fileset'},
    ]
  end

  describe 'self.instances' do
    it 'should create instances' do
      allow(@provider).to receive(:get_request).with("v2/filesystems/:all:/quotas", {'fields' => ':all:', 'entityType' => 'FILESET'}).and_return(all_quotas_data)
      expect(@provider.instances.length).to eq(3)
    end

    it 'should create no instance when no quotas returned' do
      allow(@provider).to receive(:get_request).with("v2/filesystems/:all:/quotas", {'fields' => ':all:', 'entityType' => 'FILESET'}).and_return({"quotas" => []})
      expect(@provider.instances.length).to be_zero
    end

    it 'should return the resource for a quota' do
      allow(@provider).to receive(:get_request).with("v2/filesystems/:all:/quotas", {'fields' => ':all:', 'entityType' => 'FILESET'}).and_return(all_quotas_data)
      expect(@provider.instances[0].instance_variable_get("@property_hash")).to eq(all_quotas[0])
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
    it 'should send POST request with data' do
      expected_data = {
        :operationType  => 'setQuota',
        :quotaType      => @resource[:type],
        :objectName     => @resource[:object_name],
      }
      expect(@resource.provider).to receive(:post_request).with("v2/filesystems/#{@resource[:filesystem]}/filesets/#{@resource[:fileset]}/quotas", expected_data)
      @resource.provider.create
      property_hash = @resource.provider.instance_variable_get("@property_hash")
      expect(property_hash[:ensure]).to eq(:present)
    end

=begin
    it 'should error if not path specified' do
      expect {
        @resource.provider.create
      }.to raise_error(Puppet::Error, 'Path is mandatory')
    end
=end
  end

  describe 'destroy' do
    it 'should send POST request with data' do
      expected_data = {
        :operationType  => 'setQuota',
        :quotaType      => @resource[:type],
        :objectName     => @resource[:object_name],
        :blockSoftLimit => '0',
        :blockHardLimit => '0',
        :filesSoftLimit => 0,
        :filesHardLimit => 0,
      }
      expect(@resource.provider).to receive(:post_request).with("v2/filesystems/#{@resource[:filesystem]}/filesets/#{@resource[:fileset]}/quotas", expected_data)
      @resource.provider.destroy
      property_hash = @resource.provider.instance_variable_get("@property_hash")
      expect(property_hash).to eq({})
    end
  end

  describe 'flush' do
    it 'should send POST request with data' do
      expected_uri_path = "v2/filesystems/#{@resource[:filesystem]}/filesets/#{@resource[:fileset]}/quotas"
      expected_data = {
        :operationType  => 'setQuota',
        :quotaType      => @resource[:type],
        :objectName     => @resource[:object_name],
        :blockSoftLimit => 5000,
        :blockHardLimit => 5000,
      }
      expect(@resource.provider).to receive(:post_request).with(expected_uri_path, expected_data)
      @resource.provider.block_soft_limit = 5000
      @resource.provider.block_hard_limit = 5000
      @resource.provider.flush
    end
  end

end
