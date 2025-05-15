RSpec.configure do |config|
  config.before(:all, :acceptance) do
    if inside_container?
      container_id = Socket.gethostname
      container = Docker::Container.get(container_id)

      RSpec.configuration.shared_network&.connect(container.id, nil, { "EndpointConfig" => { "Aliases" => ["my-rails-app"] } })

      # restart_server
    end
  end

  config.before(:each, :acceptance) do
    with_render_setting :browser_url, session_url

    with_lifecycle_settings :after_print, ->(_url_or_content, _browser_tab, binary_pdf_content, _filename, _controller) { store_pdf_file(binary_pdf_content, "rendered") }

    if inside_container?
      with_pdf_settings :asset_host, "http://my-rails-app:#{server_port}/"
    else
      with_pdf_settings :asset_host, "http://host.docker.internal:#{server_port}"
    end
    Bidi2pdfRails::ChromedriverManagerSingleton.initialize_manager force: true
  end

  config.after(:each, :acceptance) do
    Bidi2pdfRails::ChromedriverManagerSingleton.shutdown
  end

  config.after(:all, :acceptance) do
    if inside_container?
      container_id = Socket.gethostname
      container = Docker::Container.get(container_id)
      RSpec.configuration.shared_network&.disconnect(container.id)
    end
  end
end
