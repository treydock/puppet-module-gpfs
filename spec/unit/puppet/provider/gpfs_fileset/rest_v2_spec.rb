require 'spec_helper'

describe Puppet::Type.type(:gpfs_fileset).provider(:rest_v2) do
  let(:type) do
    Puppet::Type.type(:gpfs_fileset)
  end
  let(:resource) do
    type.new(name: 'test',
             filesystem: 'project',
             path: '/fs/project/test',
             provider: 'rest_v2')
  end

  let(:all_filesets_data) do
    {
      'filesets' => [
        { 'config' => { 'filesetName' => 'test1', 'filesystemName' => 'project', 'maxNumInodes' => 1000, 'path' => '/fs/project/test1' } },
        { 'config' => { 'filesetName' => 'test2', 'filesystemName' => 'project', 'maxNumInodes' => 2000, 'path' => '/fs/project/test2' } },
        { 'config' => { 'filesetName' => 'test1', 'filesystemName' => 'scratch', 'maxNumInodes' => 2000, 'path' => '/fs/scratch/test1' } },
      ],
      'status' => {
        'code' => 200,
        'message' => 'The request finished successfully',
      },
    }
  end

  let(:all_filesets) do
    [
      { ensure: :present, name: 'project/test1', fileset: 'test1', filesystem: 'project', path: '/fs/project/test1',
        max_num_inodes: 1000, owner: nil },
      { ensure: :present, name: 'project/test2', fileset: 'test2', filesystem: 'project', path: '/fs/project/test2',
        max_num_inodes: 2000, owner: nil },
      { ensure: :present, name: 'scratch/test1', fileset: 'test1', filesystem: 'scratch', path: '/fs/scratch/test1',
        max_num_inodes: 2000, owner: nil },
    ]
  end

  describe 'self.instances' do
    it 'creates instances' do
      allow(described_class).to receive(:get_request).with('v2/filesystems/:all:/filesets', 'fields' => ':all:').and_return(all_filesets_data)
      expect(described_class.instances.length).to eq(3)
    end

    it 'creates no instance when no filesets returned' do
      allow(described_class).to receive(:get_request).with('v2/filesystems/:all:/filesets', 'fields' => ':all:').and_return('filesets' => [])
      expect(described_class.instances.length).to be_zero
    end

    it 'returns the resource for a fileset' do
      allow(described_class).to receive(:get_request).with('v2/filesystems/:all:/filesets', 'fields' => ':all:').and_return(all_filesets_data)
      expect(described_class.instances[0].instance_variable_get('@property_hash')).to eq(all_filesets[0])
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
    it 'sends post request with data' do
      expected_data = {
        filesetName: resource[:fileset],
        path: resource[:path],
        inodeSpace: 'new',
      }
      expect(resource.provider).to receive(:post_request).with("v2/filesystems/#{resource[:filesystem]}/filesets", expected_data)
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
    it 'sends delete request' do
      expect(resource.provider).to receive(:delete_request).with("v2/filesystems/#{resource[:filesystem]}/filesets/#{resource[:name]}")
      resource.provider.destroy
      property_hash = resource.provider.instance_variable_get('@property_hash')
      expect(property_hash).to eq({})
    end
  end

  describe 'flush' do
    it 'sends PUT request with data' do
      expected_uri_path = "v2/filesystems/#{resource[:filesystem]}/filesets/#{resource[:name]}"
      expected_data = { maxNumInodes: 5000 }
      expect(resource.provider).to receive(:put_request).with(expected_uri_path, expected_data)
      resource.provider.max_num_inodes = 5000
      resource.provider.flush
    end
  end
end
