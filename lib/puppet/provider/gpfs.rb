# frozen_string_literal: true

require 'puppet'
require 'json'
require 'net/http'
require 'openssl'
require 'uri'

# Shared provider class
class Puppet::Provider::Gpfs < Puppet::Provider
  initvars

  @filesystems = nil

  class << self
    attr_accessor :base_url, :api_user, :api_password, :filesystems
  end

  commands mmlsfs: '/usr/lpp/mmfs/bin/mmlsfs'

  def self.mmlsfs_filesystems
    filesystems = []
    mmlsfs_output = mmlsfs('all', '-T', '-Y')
    mmlsfs_output.each_line do |line|
      l = line.strip.split(':')
      next if l[2] == 'HEADER'

      fs = l[6]
      if @filesystems && !@filesystems.include?(fs)
        next
      end

      filesystems << fs unless filesystems.include?(fs)
    end
    filesystems
  end

  def self.set_scalemgmt_defaults
    @base_url = 'https://localhost:443/scalemgmt/' if @base_url.nil?
    @api_user = 'admin' if @api_user.nil?
    @api_password = 'admin001' if @api_password.nil?
  end

  def self.parse_response_body(response)
    data = JSON.parse(response.body)
  rescue JSON::ParseError
    Puppet.debug('Unable to parse response body')
    data = nil
  ensure
    data
  end

  def self.response_message(response)
    data = parse_response_body(response)
    return nil if data.nil?

    message = nil
    if data.key?('status')
      message = data['status']['message']
    end
    message
  end

  def self.wait_for_job(data)
    jobid = data['jobs'][0]['jobId']
    wait = true
    while wait
      data = request("v2/jobs/#{jobid}", 'GET')
      status = data['jobs'][0]['status']
      case status
      when 'RUNNING'
        Puppet.debug("Job #{jobid} still running, sleeping 1 second...")
        sleep(1)
      when 'COMPLETED'
        stdout = data['jobs'][0]['result']['stdout']
        Puppet.debug("Job completed successfully: #{stdout.join(', ')}")
        return true, stdout.join(', ')
      else
        stderr = data['jobs'][0]['result']['stderr']
        return false, stderr.join(', ')
      end
    end
  end

  def self.request(uri_path, type, params = nil, wait = false)
    uri = URI.join(base_url, uri_path)
    header = {
      'Content-Type' => 'application/json',
      'Accept' => 'application/json'
    }
    body = nil

    case type
    when 'GET'
      if params && !params.empty?
        uri.query = URI.encode_www_form(params)
      end
      request = Net::HTTP::Get.new(uri.request_uri, header)
    when 'POST'
      request = Net::HTTP::Post.new(uri.request_uri, header)
      body = params.to_json
    when 'PUT'
      request = Net::HTTP::Put.new(uri.request_uri, header)
      body = params.to_json
    when 'DELETE'
      request = Net::HTTP::Delete.new(uri.request_uri, header)
    end
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request.basic_auth(api_user, api_password)
    Puppet.debug("Send #{type} to #{uri}")
    if body
      request.body = body
      Puppet.debug("DATA: #{body}")
    end
    response = http.request(request)
    unless response.is_a?(Net::HTTPSuccess)
      raise Puppet::Error, "#{type} to #{uri} failed with code #{response.code}, message=#{response_message(response)}"
    end

    data = parse_response_body(response)
    Puppet.debug("Response data:\n#{JSON.pretty_generate(data)}")
    return data unless wait

    job_success, job_output = wait_for_job(data)
    raise Puppet::Error, "#{type} to #{uri} job failed: #{job_output}" unless job_success
  end

  def self.get_request(uri_path, params = nil, wait = false)
    #     uri = URI.join(self.base_url, uri_path)
    #     header = {
    #       'Content-Type' => 'application/json',
    #       'Accept' => 'application/json',
    #     }
    #
    #     if params && ! params.empty?
    #       uri.query = URI.encode_www_form(params)
    #     end
    #     http = Net::HTTP.new(uri.host, uri.port)
    #     http.use_ssl = true
    #     http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    #     request = Net::HTTP::Get.new(uri.request_uri, header)
    #     request.basic_auth(self.api_user, self.api_password)
    #     Puppet.debug("Send GET to #{uri.to_s}")
    #     response = http.request(request)
    #     unless response.kind_of?(Net::HTTPSuccess)
    #       raise Puppet::Error, "GET to #{uri.to_s} failed with code #{response.code}, message=#{self.response_message(response)}"
    #     end
    #     data = self.parse_response_body(response)
    #     Puppet.debug("Response data: #{data}")
    #     return data
    request(uri_path, 'GET', params, wait)
  end

  def get_request(*args)
    self.class.get_request(*args)
  end

  def self.post_request(uri_path, data, wait = true)
    #     uri = URI.join(self.base_url, uri_path)
    #     header = {
    #       'Content-Type' => 'application/json',
    #       'Accept' => 'application/json',
    #     }
    #     http = Net::HTTP.new(uri.host, uri.port)
    #     http.use_ssl = true
    #     http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    #     request = Net::HTTP::Post.new(uri.request_uri, header)
    #     request.basic_auth(self.api_user, self.api_password)
    #     request.body = data.to_json
    #     Puppet.debug("Send POST to #{uri.to_s} with data #{data}")
    #     response = http.request(request)
    #     unless response.kind_of?(Net::HTTPSuccess)
    #       raise Puppet::Error, "POST to #{uri.to_s} failed with code #{response.code}, message=#{self.response_message(response)}"
    #     end
    #     data = self.parse_response_body(response)
    #     Puppet.debug("Response data: #{data}")
    #     return data
    request(uri_path, 'POST', data, wait)
  end

  def post_request(*args)
    self.class.post_request(*args)
  end

  def self.put_request(uri_path, data, wait = true)
    #     uri = URI.join(self.base_url, uri_path)
    #     header = {
    #       'Content-Type' => 'application/json',
    #       'Accept' => 'application/json',
    #     }
    #     http = Net::HTTP.new(uri.host, uri.port)
    #     http.use_ssl = true
    #     http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    #     request = Net::HTTP::Put.new(uri.request_uri, header)
    #     request.basic_auth(self.api_user, self.api_password)
    #     request.body = data.to_json
    #     Puppet.debug("Send PUT to #{uri.to_s} with data #{data}")
    #     response = http.request(request)
    #     unless response.kind_of?(Net::HTTPSuccess)
    #       raise Puppet::Error, "PUT to #{uri.to_s} failed with code #{response.code}, message=#{self.response_message(response)}"
    #     end
    #     data = self.parse_response_body(response)
    #     Puppet.debug("Response data: #{data}")
    #     return data
    request(uri_path, 'PUT', data, wait)
  end

  def put_request(*args)
    self.class.put_request(*args)
  end

  def self.delete_request(uri_path, wait = true)
    #     uri = URI.join(self.base_url, uri_path)
    #     header = {
    #       'Content-Type' => 'application/json',
    #       'Accept' => 'application/json',
    #     }
    #
    #     http = Net::HTTP.new(uri.host, uri.port)
    #     http.use_ssl = true
    #     http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    #     request = Net::HTTP::Delete.new(uri.request_uri, header)
    #     request.basic_auth(self.api_user, self.api_password)
    #     Puppet.debug("Send DELETE to #{uri.to_s}")
    #     response = http.request(request)
    #     unless response.kind_of?(Net::HTTPSuccess)
    #       raise Puppet::Error, "DELETE to #{uri.to_s} failed with code #{response.code}, message=#{self.response_message(response)}"
    #     end
    #     data = self.parse_response_body(response)
    #     Puppet.debug("Response data: #{data}")
    #     return data
    request(uri_path, 'DELETE', wait)
  end

  def delete_request(*args)
    self.class.delete_request(*args)
  end

  def self.human_readable_kilobytes(value)
    return '0' if value.to_i.zero?

    {
      'K' => 1024,
      'M' => 1024**2,
      'G' => 1024**3,
      'T' => 1024**4
    }.each_pair do |suffix, factor|
      next unless value < factor

      factored_value = (value.to_f / (factor / 1024))
      # Check if integer value is same as float rounded to one decimal place
      return "#{Integer(factored_value)}#{suffix}" if Integer(factored_value) == factored_value.round(1)

      return "#{factored_value.round(1)}#{suffix}"
    end
    value
  end

  def self.to_kb(value)
    factors = {
      'M' => 1024,
      'G' => 1024**2,
      'T' => 1024**3
    }
    if value =~ %r{^([0-9.]+)(T|G|M)$}
      v = Regexp.last_match(1).to_f
      f = Regexp.last_match(2)
      factor = factors[f]
      "#{Integer(v * factor)}K"
    else
      value
    end
  end
end
