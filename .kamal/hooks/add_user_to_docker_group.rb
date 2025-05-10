# frozen_string_literal: true

class AddUserToDockerGroup < Kamal::Commands::Docker
  def can_use_docker_cli?
    ["docker", "info", "--format", "{{.ServerVersion}}"]
  end

  def needs_sudo?
    ["test", "$(id -u)", "-ne", "0"] # Returns true if user is not root
  end

  def update_group(requires_sudo)
    shell \
      [requires_sudo ? :sudo : nil, "usermod", "-aG", "docker", "$(id -u -n)"].compact

  end
end