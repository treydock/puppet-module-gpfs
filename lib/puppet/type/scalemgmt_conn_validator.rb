# frozen_string_literal: true

Puppet::Type.newtype(:scalemgmt_conn_validator) do
  @doc = "Verify that a connection can be successfully established between a node
          and the scalemgmt server.  Its primary use is as a precondition to
          prevent configuration changes from being applied if the scalemgmt
          server cannot be reached, but it could potentially be used for other
          purposes such as monitoring."

  ensurable do
    desc 'Ensure'
    defaultvalues
    defaultto :present
  end

  newparam(:name, namevar: true) do
    desc 'An arbitrary name used as the identity of the resource.'
  end

  newparam(:scalemgmt_server) do
    desc 'The DNS name or IP address of the server where scalemgmt should be running.'
    defaultto 'localhost'
  end

  newparam(:scalemgmt_port) do
    desc 'The port that the scalemgmt server should be listening on.'
    defaultto '443'
  end

  newparam(:api_user) do
    desc 'API user name'
    defaultto 'admin'
  end

  newparam(:api_password) do
    desc 'API password'
    defaultto 'admin001'
  end

  newparam(:test_url) do
    desc 'URL to use for testing if the scalemgmt API is up'
    defaultto '/scalemgmt/v2/info'
  end

  newparam(:timeout) do
    desc 'The max number of seconds that the validator should wait before giving up and deciding that scalemgmt is not running; defaults to 30 seconds.'
    defaultto 30

    validate do |value|
      # This will raise an error if the string is not convertible to an integer
      Integer(value)
    end

    munge do |value|
      Integer(value)
    end
  end

  autorequire(:service) do
    ['gpfsgui']
  end
end
