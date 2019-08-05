def verify_concat_fragment_exact_contents(subject, title, expected_lines)
  content = subject.resource('concat::fragment', title).send(:parameters)[:content]
  expect(content.split(/\n/).reject { |line| line =~ /(^#|^$|^\s+#)/ }).to eq(expected_lines)
end

include RspecPuppetFacts
add_custom_fact :service_provider, ->(os, facts) {
  case facts[:operatingsystemmajrelease]
  when '6'
    'redhat'
  else
    'systemd'
  end
}
