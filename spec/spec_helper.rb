ENV["SCRIPT_ENV"] = 'test'

ROOT_DIR = Pathname.new(File.expand_path('..', __dir__)) unless defined?(ROOT_DIR)
$LOAD_PATH.unshift(ROOT_DIR) unless $LOAD_PATH.include?(ROOT_DIR)

require 'things'

Dir.glob(File.join(ROOT_DIR, '/lib/**/*.rb'), &method(:require))

RSpec.configure do |config|
  config.color = true
end
