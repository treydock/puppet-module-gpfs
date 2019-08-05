

## Development

### Testing

Unit tests

    bundle exec rake test

Acceptance test example run from OSC

    BEAKER_gpfs_repo_url='http://rhn.osc.edu/pub/mirror/gpfs/$releasever/' \
    BEAKER_set="centos-7-x64" \
    BEAKER_provision=yes \
    BEAKER_destroy=no \
    bundle exec rspec spec/acceptance/*_spec.rb
