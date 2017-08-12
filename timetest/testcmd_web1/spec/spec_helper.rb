
require 'infrataster/rspec'

Infrataster::Server.define(
  :app,             # name
  '192.168.33.20',  # ip address
  
  ssh: {user: 'vagrant', password: 'vagrant'},
  
  vagrant: true     # for vagrant VM
)

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

end
