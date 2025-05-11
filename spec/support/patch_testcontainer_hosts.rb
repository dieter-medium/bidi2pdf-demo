module PatchTestcontainerHosts
  def host
    host = docker_host
    return "localhost" if host.nil?
    raise ContainerNotStartedError unless @_container

    if inside_container? && ENV["DOCKER_HOST"].nil?
      gateway_ip = container_gateway_ip
      return container_bridge_ip if gateway_ip == host
      return gateway_ip
    end
    host
  rescue Excon::Error::Socket => e
    raise ConnectionError, e.message
  end

  def _container_create_options
    opts = super

    opts["HostConfig"]["ExtraHosts"] = ["host.docker.internal:host-gateway"] if ENV["CI"]

    opts.compact
  end

  def container_bridge_ip
    network_settings&.fetch("IPAddress")
  end

  def container_gateway_ip
    network_settings&.fetch("Gateway")
  end

  def network_settings
    @_container&.json&.dig("NetworkSettings", "Networks", @_network&.json&.dig("Name") || "bridge")
  end
end

Testcontainers::DockerContainer.prepend(PatchTestcontainerHosts)
