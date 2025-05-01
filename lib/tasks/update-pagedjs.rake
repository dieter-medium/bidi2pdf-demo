# frozen_string_literal: true

#
# A rake task to download the newest ESM version of pagedjs from https://unpkg.com/pagedjs/dist/paged.esm.js
# into the folder vendor/javascript/paged.esm-<version>.js

namespace :update_pagedjs do
  desc "Download the newest ESM version of pagedjs. Usage: rake update_pagedjs:download[version] VERBOSE=1 DRY_RUN=1 OUT=vendor/javascript"
  task :download, [ :version ] do |_, args|
    require "net/http"
    require "uri"
    require "fileutils"
    require "json"

    verbose = ENV["VERBOSE"] == "1"
    dry_run = ENV["DRY_RUN"] == "1"
    out_dir = ENV["OUT"] || "vendor/javascript"
    version = args[:version]

    begin
      pagedjs_downloader = PagedjsDownloader.new(
        verbose: verbose,
        dry_run: dry_run,
        out_dir: out_dir
      )
      pagedjs_downloader.download(version)
    rescue SocketError, Timeout::Error => e
      puts "Network error: #{e.class} - #{e.message}"
      exit 1
    end
  end

  class PagedjsDownloader
    def initialize(verbose: false, dry_run: false, out_dir: "vendor/javascript")
      @verbose = verbose
      @dry_run = dry_run
      @out_dir = out_dir
    end

    def download(version = nil)
      version ||= fetch_latest_version
      return unless version

      response = download_file(version)
      return unless response

      save_file(response, version)
    end

    private

    def fetch_latest_version
      npm_registry_url = "https://registry.npmjs.org/pagedjs"
      registry_uri = URI.parse(npm_registry_url)
      http = create_http_client(registry_uri)
      registry_response = http.get(registry_uri.path)

      if registry_response.is_a?(Net::HTTPSuccess)
        package_data = JSON.parse(registry_response.body)
        version = package_data["dist-tags"]["latest"]
        puts "Latest version of pagedjs: #{version}" if @verbose
        version
      else
        puts "Failed to get latest version from NPM registry: #{registry_response.code} #{registry_response.message}"
        nil
      end
    rescue => e
      puts "Error fetching latest version: #{e.class} - #{e.message}"
      nil
    end

    def download_file(version)
      url = "https://unpkg.com/pagedjs@#{version}/dist/paged.esm.js"
      uri = URI.parse(url)
      http = create_http_client(uri)
      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)
      response = follow_redirects(response)
      if response.is_a?(Net::HTTPSuccess)
        log_headers(response)
        response
      else
        puts "Failed to download paged.js: #{response.code} #{response.message}"
        nil
      end
    rescue => e
      puts "Error downloading file: #{e.class} - #{e.message}"
      nil
    end

    def follow_redirects(response, max_redirects = 10)
      redirect_count = 0
      while response.is_a?(Net::HTTPRedirection) && redirect_count < max_redirects
        redirect_url = response["location"]
        redirect_uri = URI.parse(redirect_url)
        puts "Redirecting to #{redirect_url}" if @verbose
        http = create_http_client(redirect_uri)
        request = Net::HTTP::Get.new(redirect_uri.path)
        response = http.request(request)
        redirect_count += 1
      end
      response
    end

    def save_file(response, version)
      file_path = File.join(@out_dir, "paged.esm-#{version}.js")
      if File.exist?(file_path)
        backup_path = "#{file_path}.bak"
        puts "Backing up existing file to #{backup_path}" if @verbose
        FileUtils.mv(file_path, backup_path) unless @dry_run
      end

      puts "Would write to #{file_path}" if @dry_run
      unless @dry_run
        FileUtils.mkdir_p(File.dirname(file_path))
        File.open(file_path, "wb") { |file| file.write(response.body) }
        puts "Paged.js v#{version} downloaded to #{file_path}"
      end
    end

    def create_http_client(uri)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.scheme == "https")
      http.open_timeout = 10
      http.read_timeout = 30
      http
    end

    def log_headers(response)
      return unless @verbose
      puts "Response headers:"
      response.each_header { |k, v| puts "  #{k}: #{v}" }
    end
  end
end
