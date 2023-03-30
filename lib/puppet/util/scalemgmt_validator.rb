# frozen_string_literal: true

require 'net/http'
require 'openssl'

# Validator class, for testing that scalemgmt is alive
class Puppet::Util::ScalemgmtValidator
  attr_reader :scalemgmt_server, :scalemgmt_port, :api_user, :api_password, :test_path, :test_headers

  def initialize(scalemgmt_server, scalemgmt_port, api_user = 'admin', api_password = 'admin001', test_path = '/scalemgmt/v2/info')
    @scalemgmt_server = scalemgmt_server
    @scalemgmt_port   = scalemgmt_port
    @api_user         = api_user
    @api_password     = api_password
    @test_path        = test_path
    @test_headers     = { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }
  end

  # Utility method; attempts to make an https connection to the scalemgmt server.
  # This is abstracted out into a method so that it can be called multiple times
  # for retry attempts.
  #
  # @return true if the connection is successful, false otherwise.
  def attempt_connection
    # All that we care about is that we are able to connect successfully via
    # https, so here we're simpling hitting a somewhat arbitrary low-impact URL
    # on the scalemgmt server.
    http = Net::HTTP.new(scalemgmt_server, scalemgmt_port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(test_path, test_headers)
    request.basic_auth(api_user, api_password)

    response = http.request(request)
    unless response.is_a?(Net::HTTPSuccess)
      Puppet.notice "Unable to connect to scalemgmt server (https://#{scalemgmt_server}:#{scalemgmt_port}): [#{response.code}] #{response.msg}"
      return false
    end
    true
  rescue Exception => e # rubocop:disable Lint/RescueException
    Puppet.notice "Unable to connect to scalemgmt server (https://#{scalemgmt_server}:#{scalemgmt_port}): #{e.message}"
    false
  end
end
