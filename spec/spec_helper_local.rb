# frozen_string_literal: true

def verify_concat_fragment_exact_contents(subject, title, expected_lines)
  content = subject.resource('concat::fragment', title).send(:parameters)[:content]
  expect(content.split(%r{\n}).reject { |line| line =~ %r{(^#|^$|^\s+#)} }).to eq(expected_lines)
end

include RspecPuppetFacts # rubocop:disable Style/MixinUsage
add_custom_fact :service_provider, ->(_os, facts) {
  case facts[:operatingsystemmajrelease]
  when '6'
    'redhat'
  else
    'systemd'
  end
}
add_custom_fact :kernelrelease, ->(_os, facts) {
  case facts[:operatingsystemmajrelease]
  when '6'
    '2.6.32-754.18.2.el6.x86_64'
  else
    '3.10.0-957.12.2.el7.x86_64'
  end
}
