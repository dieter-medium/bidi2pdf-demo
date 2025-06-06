require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_mailbox/engine"
require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Bidi2pdfDemo
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Don't generate system test files.
    config.generators.system_tests = nil

    if ENV["IN_DEV_CONTAINER"] && ENV["IN_DEV_CONTAINER"] == "true"
      config.hosts << "rails-app"
    end

    if ENV["CODESPACES"] && ENV["CODESPACES"] == "true"
      codespace = ENV["CODESPACE_NAME"]

      regex = /\A#{Regexp.escape(codespace)}-\d+\.app\.github\.dev\z/
      config.hosts << regex
    end

    if ENV["ALLOWED_HOSTS"]
      #  Additional comma-separated hosts
      ENV["ALLOWED_HOSTS"].split(",").each do |host|
        config.hosts << host.strip
      end

      config.hosts << ENV["HOSTNAME"]
    end

    config.host_authorization = {
      exclude: ->(request) { request.path.include?("healthcheck") || request.path.include?("up") }
    }
  end
end
