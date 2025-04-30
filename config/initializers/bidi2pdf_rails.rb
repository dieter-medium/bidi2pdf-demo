# frozen_string_literal: true

Bidi2pdfRails.configure do |config|

  #
  # General Options
  #

  # config.general_options.logger = Rails.logger # The logger  

  # Allowed values: "none", "low", "medium", "high"
  config.general_options.verbosity = "medium" # How verbose to be  
  # config.general_options.headless = !Rails.env.development? # Run Chrome in headless mode  
  # config.general_options.wait_for_network_idle = true # Wait for network idle  
  config.general_options.wait_for_page_loaded = true # Wait for page loaded
  # config.general_options.wait_for_page_check_script = nil # Wait for page check script  
  # config.general_options.notification_service = -> { ActiveSupport::Notifications } # Notification service  
  # config.general_options.default_timeout = 10 # Default timeout for various Bidi commands  
  # config.general_options.chrome_session_args = ["--disable-gpu", "--disable-popup-blocking", "--disable-hang-monitor"] # Chrome session arguments  

  #
  # Chromedriver Settings (when chromedriver run within your app)
  #

  # config.chromedriver_settings.install_dir = nil # Chromedriver install directory  
  # config.chromedriver_settings.port = 0 # Chromedriver port  

  #
  # Proxy Settings
  #

  # config.proxy_settings.addr = nil # Proxy address (e.g., 127.0.0.1)  
  # config.proxy_settings.port = nil # Proxy port (e.g., 8080)  
  # config.proxy_settings.user = nil # Proxy user  
  # config.proxy_settings.pass = -> { Rails.application.credentials.dig('bidi2pdf_rails', 'proxy_pass') } # Proxy password  

  #
  # PDF Settings
  #

  # Allowed values: "portrait", "landscape"
  # config.pdf_settings.orientation = "portrait" # PDF orientation (portrait/landscape)  
  # config.pdf_settings.margins = false # Configure PDF margins?  
  # config.pdf_settings.margin_top = 2.5 # PDF margin top (cm)  
  # config.pdf_settings.margin_bottom = 2 # PDF margin bottom (cm)  
  # config.pdf_settings.margin_left = 2 # PDF margin left (cm)  
  # config.pdf_settings.margin_right = 2 # PDF margin right (cm)  

  # Allowed values: "letter", "legal", "tabloid", "ledger", "a0", "a1", "a2", "a3", "a4", "a5", "a6"
  # config.pdf_settings.page_format = nil # PDF page format (e.g., A4)  
  # config.pdf_settings.page_width = 21.0 # PDF page width (cm, not needed when format is specified)  
  # config.pdf_settings.page_height = 29.7 # PDF page height (cm, not needed when format is specified)  
  # config.pdf_settings.print_background = true # Print background graphics?  
  # config.pdf_settings.scale = 1.0 # PDF scale (e.g., 1.0)  
  # config.pdf_settings.shrink_to_fit = false # Shrink to fit?  
  # config.pdf_settings.custom_js = nil # Raw JavaScript code to inject before PDF generation (without <script> tags)  
  # config.pdf_settings.custom_css = nil # Raw CSS styles to inject before PDF generation (without <style> tags)  
  # config.pdf_settings.custom_js_url = nil # URL to JavaScript file to load before PDF generation  
  # config.pdf_settings.custom_css_url = nil # URL to CSS file to load before PDF generation
  config.pdf_settings.asset_host = ->(_controller) { ENV["IN_DEV_CONTAINER"] && ENV["IN_DEV_CONTAINER"] == "true" ? "http://rails-app:3000/" : nil } # Asset hosts (e.g. http://rails-app:3001)

  #
  # Remote URL Settings
  #

  if ENV["IN_DEV_CONTAINER"] && ENV["IN_DEV_CONTAINER"] == "true"
    config.render_remote_settings.browser_url = "http://remote-chrome:3000/session" # Remote browser URL (e.g. http://localhost:3001/sesion)
  end
  # config.render_remote_settings.basic_auth_user = nil # Basic auth user  
  # config.render_remote_settings.basic_auth_pass = -> { Rails.application.credentials.dig('bidi2pdf_rails', 'basic_auth_pass') } # Basic auth password  
  # config.render_remote_settings.headers = {"X-API-INFO" => "my info"} # Headers to be send when allong an url  
  # config.render_remote_settings.cookies = {"session_id" => "my session"} # Cookies to be send when alling an url  

  #
  # Lifecycle Settings
  #

  # config.lifecycle_settings.before_navigate = ->(url_or_content, browser_tab, filename, controller) { Rails.logger.tagged("bidi2pdf-rails").info "Navigating to #{url_or_content}" } # Hook to be called before navigating to a URL  
  config.lifecycle_settings.after_navigate = ->(url_or_content, browser_tab, filename, controller) { Rails.logger.tagged("bidi2pdf-rails").info "Navigated to #{url_or_content}" } # Hook to be called after navigating to a URL
  # config.lifecycle_settings.after_wait_for_tab = ->(url_or_content, browser_tab, filename, controller) { Rails.logger.tagged("bidi2pdf-rails").info "Waited for #{url_or_content}" } # Hook to be called after waiting for a tab  (when waiting is enabled)  
  # config.lifecycle_settings.after_print = ->(url_or_content, browser_tab, binary_pdf_content, filename, controller) { Rails.logger.tagged("bidi2pdf-rails").info "Printed #{url_or_content}"; binary_pdf_content } # Hook to be called after printing, needs to return the pdf-binary-content. Here you can store the content into a file, sign it, or add meta data.  

  # Values can be used from the environment or from the config file.
  # with the following pattern:
  # overrides = Rails.application.config.x.bidi2pdf_rails
  # config.general_options.verbosity = overrides.verbosity if overrides.verbosity
end

Rails.application.config.after_initialize do |_app|
  Bidi2pdfRails::MainLogSubscriber.attach_to "bidi2pdf", inherit_all: true # needed for imported methods
  Bidi2pdfRails::MainLogSubscriber.attach_to "bidi2pdf_rails", inherit_all: true # needed for imported methods

  Bidi2pdfRails::BrowserConsoleLogSubscriber.attach_to "bidi2pdf"

  Bidi2pdfRails::MainLogSubscriber.silence /network_event_.*\.bidi2pdf/

  Bidi2pdfRails::NetworkLogSubscriber.attach_to "bidi2pdf"
end

Importmap::ImportmapTagsHelper.prepend Bidi2pdfRails::Services::ImportmapTagsHelperOverride
