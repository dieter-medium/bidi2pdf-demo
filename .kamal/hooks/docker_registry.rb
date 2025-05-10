# frozen_string_literal: true

class DockerRegistry < Kamal::Commands::Docker
  def needs_sudo?
    ["test", "$(id -u)", "-ne", "0"] # Returns true if user is not root
  end

  def daemon_config_exists?
    ["test", "-f", "/etc/docker/daemon.json"]
  end

  def restart
    chain stop, start
  end

  def start
    docker :compose, "-f", "#{base_dir}/compose.yml", :up, "-d", "--remove-orphans", "--force-recreate", "--wait"
  end

  def stop
    docker :compose, "-f", "#{base_dir}/compose.yml", :down, "--remove-orphans"
  end

  def make_directory_for(remote_file)
    make_directory Pathname.new(remote_file).dirname.to_s
  end

  def base_dir
    "registry"
  end

  def allow_insecure_registries
    shell [
            :sudo,
            shell(
              combine(
                [:cp, "#{base_dir}/daemon.json", "/etc/docker/daemon.json"],
                [:systemctl, "restart", "docker"],
              # [:pkill, "sshd"] # harsh, but no other way to force the parent process to reconnect
              )
            )
          ]
  end

  def daemon_config
    daemon_config = {
      "insecure-registries" => [
        "#{config.primary_host}:5043"
      ]
    }
    daemon_config_io = StringIO.new(daemon_config.to_json)

    [
      daemon_config_io,
      "#{base_dir}/daemon.json"
    ]
  end

  def directories
    [base_dir, "#{base_dir}/data"]
  end

  def passwd
    registry_config ||= config.registry

    ht_username = registry_config.username
    ht_password = registry_config.password

    hashed_password = BCrypt::Password.create(ht_password)
    htpasswd_content = "#{ht_username}:#{hashed_password}\n"

    htpasswd_io = StringIO.new(htpasswd_content)

    [htpasswd_io, "#{base_dir}/auth/nginx.htpasswd"]
  end

  def generate_sh
    file = "certs/generate.sh"
    [
      Pathname.new(File.expand_path("../registry/#{file}", __dir__)).to_s,
      {
        name: "#{base_dir}/#{file}",
        mode: "755",
      }
    ]
  end

  def openssl_conf
    file = "certs/openssl.conf"
    local = Pathname.new(File.expand_path("../registry/#{file}.erb", __dir__)).to_s
    local_file_io = StringIO.new(ERB.new(File.read(local)).result)
    remote = "#{base_dir}/#{file}"

    [local_file_io, remote]
  end

  def files
    %w[compose.yml auth/nginx.conf ].map do |file|
      local = Pathname.new(File.expand_path("../registry/#{file}", __dir__)).to_s
      remote = "#{base_dir}/#{file}"

      [local, remote]
    end + [passwd, generate_sh, openssl_conf]
  end
end