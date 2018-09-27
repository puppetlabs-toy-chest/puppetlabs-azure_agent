require 'rubygems'
require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet-facts'

RSpec.configure do |c|
  include RspecPuppetFacts
  c.fail_fast = true
  c.before :each do
    # Prevent 'fact "clientversion" already has the maximum number of resolutions allowed (100).' error
    Facter.clear
  end
end

at_exit { RSpec::Puppet::Coverage.report! }
