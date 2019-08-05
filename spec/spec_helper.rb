require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet-facts'

include RspecPuppetFacts

begin
  require 'simplecov'
  require 'coveralls'
  SimpleCov.formatter = Coveralls::SimpleCov::Formatter
  SimpleCov.start do
    add_filter '/spec/'
  end
rescue Exception => e
  warn "Coveralls disabled"
end

dir = File.expand_path(File.dirname(__FILE__))
Dir["#{dir}/shared_examples/**/*.rb"].sort.each {|f| require f}

at_exit { RSpec::Puppet::Coverage.report! }

RSpec.configure do |config|
  config.mock_with :rspec
end

def verify_concat_fragment_contents(subject, title, expected_lines)
  content = subject.resource('concat::fragment', title).send(:parameters)[:content]
  expect(content.split("\n") & expected_lines).to eq(expected_lines)
end

def verify_concat_fragment_exact_contents(subject, title, expected_lines)
  content = subject.resource('concat::fragment', title).send(:parameters)[:content]
    expect(content.split(/\n/).reject { |line| line =~ /(^#|^$|^\s+#)/ }).to eq(expected_lines)
end

add_custom_fact :service_provider, ->(os, facts) {
  case facts[:operatingsystemmajrelease]
  when '6'
    'redhat'
  else
    'systemd'
  end
}
