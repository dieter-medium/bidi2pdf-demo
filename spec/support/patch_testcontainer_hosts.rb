module PatchTestcontainerHosts
  def _container_create_options
    opts = super

    opts["HostConfig"]["ExtraHosts"] = [ "host.docker.internal:host-gateway" ] if ENV["CI"]

    opts.compact
  end

  def container_bridge_ip
    network_settings&.fetch("IPAddress")
  end

  def container_gateway_ip
    network_settings&.fetch("Gateway")
  end

  def network_settings
    @_container&.json&.dig("NetworkSettings", "Networks", @_network&.name || "bridge")
  end
end

Testcontainers::DockerContainer.prepend(PatchTestcontainerHosts)
