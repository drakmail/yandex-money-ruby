require 'coveralls'
Coveralls.wear!

require 'bundler/setup'
Bundler.setup

require 'yandex_money/api'
require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock
end

RSpec.configure do |config|
  # some (optional) config here
end
