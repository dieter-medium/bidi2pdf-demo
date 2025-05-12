# frozen_string_literal: true

#
# A rake task to download the newest ESM version of pagedjs from https://unpkg.com/pagedjs/dist/paged.esm.js
# into the folder vendor/javascript/paged.esm-<version>.js

require_relative "pagedjs_downloader"

namespace :update_pagedjs do
  desc "Download the newest ESM version of pagedjs. Usage: rake update_pagedjs:download[version] VERBOSE=1 DRY_RUN=1 OUT=vendor/javascript"
  task :download, [:version] do |_, args|
    require "net/http"
    require "uri"
    require "fileutils"
    require "json"

    verbose = ENV["VERBOSE"] == "1"
    dry_run = ENV["DRY_RUN"] == "1"
    out_dir = ENV["OUT"] || "app/javascript/vendor"
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
end
