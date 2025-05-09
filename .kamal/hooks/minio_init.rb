# frozen_string_literal: true

class MinioInit < Kamal::Commands::Docker

  delegate :service_name, :image, :hosts, :port, :files, :directories, :cmd,
           :network_args, :publish_args, :env_args, :volume_args, :label_args, :option_args,
           :secrets_io, :secrets_path, :env_directory, :proxy, :running_proxy?, :registry,
           to: :accessory_config

  def minio_host?(current_host)
    hosts.include?(current_host)
  end

  def ensure_bucket
    docker :exec, service_name, "/create_bucket.sh"
  end

  def accessory_config
    config.accessories.find { |a| a.name == "minio" }
  end
end