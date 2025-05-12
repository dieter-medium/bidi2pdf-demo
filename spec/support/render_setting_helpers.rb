# frozen_string_literal: true

#
module RenderSettingHelpers
  def with_render_setting(key, value)
    overridden_render_settings[key] = Bidi2pdfRails.config.render_remote_settings.public_send(key)
    Bidi2pdfRails.config.render_remote_settings.public_send("#{key}=", value)
  end

  def with_pdf_settings(key, value)
    overridden_pdf_settings[key] = Bidi2pdfRails.config.pdf_settings.public_send(key)
    Bidi2pdfRails.config.pdf_settings.public_send("#{key}=", value)
  end

  def with_lifecycle_settings(key, value)
    overridden_lifecycle_settings[key] = Bidi2pdfRails.config.lifecycle_settings.public_send(key)
    Bidi2pdfRails.config.lifecycle_settings.public_send("#{key}=", value)
  end

  def overridden_render_settings
    @__overridden_render_settings ||= {}
  end

  def overridden_pdf_settings
    @__overridden_pdf_settings ||= {}
  end

  def overridden_lifecycle_settings
    @__overridden_lifecycle_settings ||= {}
  end

  def reset_render_settings
    overridden_render_settings.each do |key, original_value|
      Bidi2pdfRails.config.render_remote_settings.public_send("#{key}=", original_value)
    end

    @__overridden_render_settings = {}
  end

  def reset_pdf_settings
    overridden_pdf_settings.each do |key, original_value|
      Bidi2pdfRails.config.pdf_settings.public_send("#{key}=", original_value)
    end

    @__overridden_pdf_settings = {}
  end

  def reset_lifecycle_settings
    overridden_lifecycle_settings.each do |key, original_value|
      Bidi2pdfRails.config.lifecycle_settings.public_send("#{key}=", original_value)
    end

    @__overridden_lifecycle_settings = {}
  end
end

RSpec.configure do |config|
  config.include RenderSettingHelpers, type: :request

  config.after(:each, type: :request) do
    reset_render_settings if respond_to?(:reset_render_settings)
    reset_pdf_settings if respond_to?(:reset_pdf_settings)
    reset_lifecycle_settings if respond_to?(:reset_lifecycle_settings)
  end
end
