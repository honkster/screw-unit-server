require "rubygems"
require "spec"
require "spec/autorun"
require "selenium_rc"
dir = File.dirname(__FILE__)
require "#{dir}/functional_spec_server_starter"

Spec::Runner.configure do |config|
  config.mock_with :rr
end

class Spec::ExampleGroup
  include WaitFor
  attr_reader :spec_root_path, :implementation_root_path, :public_path

  before(:all) do
    @spec_root_path = FunctionalSpecServerStarter.spec_root_path
    @public_path = FunctionalSpecServerStarter.public_path
    @implementation_root_path = FunctionalSpecServerStarter.implementation_root_path
    unless SeleniumRC::Server.service_is_running?
      Thread.start do
        SeleniumRC::Server.boot
      end
    end
    FunctionalSpecServerStarter.call
    TCPSocket.wait_for_service :host => "0.0.0.0", :port => "4444"
  end

  def root_url
    "http://#{ScrewUnit::DEFAULT_HOST}:#{ScrewUnit::DEFAULT_PORT}"
  end
end

