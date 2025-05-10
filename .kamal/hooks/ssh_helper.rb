# frozen_string_literal: true
require_relative "add_user_to_docker_group"
require_relative "docker_registry"
require_relative "minio_init"

class SSHHelper
  include SSHKit::DSL

  attr_reader :config, :missing

  def initialize(config)
    @config = config
    @missing = []
  end

  def patch_docker_hosts(hosts)
    @missing = []

    hosts.each { |current_host| patch_docker_host(current_host) }

    return puts "✅ All hosts updated successfully." if missing.empty?

    raise "❌ Docker permissions could not be fixed on: #{missing.join(', ')}"
  end

  def patch_docker_host(current_host)
    puts "📡 Connecting to #{current_host}"

    patch_groups(current_host)

    install_docker_registry(current_host) if current_host == config.primary_host

    patch_docker_registry_settings(current_host)
  end

  def patch_docker_registry_settings(current_host)
    that = self

    on(current_host) do
      execute *that.docker_registry_cmd.make_directory_for(that.docker_registry_cmd.daemon_config[1])
      upload! *that.docker_registry_cmd.daemon_config

      if execute(*that.docker_registry_cmd.daemon_config_exists?, raise_on_non_zero_exit: false)
        info "Daemon config already exists on #{current_host}, skipping installation …"
      else
        execute *that.docker_registry_cmd.allow_insecure_registries
      end
    end
  end

  def patch_groups(current_host)
    that = self

    on(current_host) do
      info "⚙️ Ensuring docker group is properly configured on #{current_host}"

      unless execute(*that.docker_group_cmd.can_use_docker_cli?, raise_on_non_zero_exit: false)
        if execute(*that.docker_group_cmd.superuser?, raise_on_non_zero_exit: false)
          info "⚠️ User NOT in 'docker' group on #{current_host}, attempting fix…"

          requires_sudo = execute(*that.docker_group_cmd.needs_sudo?, raise_on_non_zero_exit: false)

          execute(*that.docker_group_cmd.update_group(requires_sudo))

          info "🎉 Docker group updated on #{current_host}"
        else
          missing << current_host
        end
      end
    end

    # make new group visible to SSHKit
    SSHKit::Backend::Netssh.pool.close_connections
  end

  def init_minio(hosts)
    hosts.each do |current_host|
      _init_minio(current_host)
    end
  end

  def _init_minio(current_host)
    return unless minio_cmd.minio_host?(current_host)

    that = self

    on(current_host) do
      info "Initializing minio on #{current_host}"
      execute *that.minio_cmd.ensure_bucket
    end
  end

  def install_docker_registry(current_host)
    that = self
    puts "Installing docker registry on #{current_host}"

    on(current_host) do
      that.docker_registry_cmd.directories.each { |dir| execute *that.docker_registry_cmd.make_directory(dir) }

      that.docker_registry_cmd.files.each do |local, remote|
        remote_file = remote.is_a?(String) ? remote : remote[:name]
        remote_mode = remote.is_a?(String) ? "644" : remote[:mode]

        info "Uploading #{local} to #{remote_file} on #{current_host}"
        that.ensure_local_file_present(local)

        execute *that.docker_registry_cmd.make_directory_for(remote_file)

        upload! local, remote_file
        execute :chmod, remote_mode, remote_file
      end

      info "Starting docker registry on #{current_host}"

      execute *that.docker_registry_cmd.restart
    end
  end

  def docker_group_cmd
    @docker_group_cmd ||= AddUserToDockerGroup.new(@config)
  end

  def docker_registry_cmd
    @docker_registry_cmd ||= DockerRegistry.new(@config)
  end

  def minio_cmd
    @minio_cmd ||= MinioInit.new(@config)
  end

  def ensure_local_file_present(local_file)
    if !local_file.is_a?(StringIO) && !Pathname.new(local_file).exist?
      raise "Missing file: #{local_file}"
    end
  end
end