module PatchTestcontainerHosts
  def _container_create_options
    opts = super

    opts["HostConfig"]["ExtraHosts"] = [ "host.docker.internal:host-gateway" ] if ENV["CI"]

    opts.compact
  end
end

Testcontainers::DockerContainer.prepend(PatchTestcontainerHosts)
