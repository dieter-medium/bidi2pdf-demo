# spec/support/request_server_bootstrap.rb

require "socket"
require "net/http"
require "rack/handler/puma"
module RequestServerBootstrap
  def find_available_port
    server = TCPServer.new('127.0.0.1', 0)
    port = server.addr[1]
    server.close
    port
  end

  def wait_until_server_is_ready(port)
    loop do
      begin
        Net::HTTP.get(URI("http://localhost:#{port}"))
        break
      rescue Errno::ECONNREFUSED
        sleep 0.1
      end
    end
  end

  def capybara_manages_server?
    defined?(Capybara) && Capybara.current_driver && Capybara.server
  end
end

RSpec.configure do |config|
  config.include RequestServerBootstrap, type: :request

  config.before(:all, type: :request) do
    next if capybara_manages_server?
    @port = find_available_port
    @server_thread = Thread.new do
      Rack::Handler::Puma.run Rails.application, Port: @port, Silent: false
    end

    wait_until_server_is_ready(@port)
  end

  config.after(:all, type: :request) do
    next if capybara_manages_server?
    @server_thread&.exit
  end
end
