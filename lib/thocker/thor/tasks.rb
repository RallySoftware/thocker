require 'thocker'

#
# Project tasks. These tasks are intended to be included from a project's
# Thorfile.
module Thocker
  class Tasks < Thor
    include Thor::RakeCompat
    include Thocker::Mixin::ShellOut
    include Thocker::Mixin::DockerAPI
    include Thocker::Mixin::Net

    RSpec::Core::RakeTask.new(:spec) do |t|
      t.pattern = 'spec/*/*_spec.rb'
    end

    namespace :default

    def initialize(*args)
      super
      Docker.url = "tcp://#{docker_host}:#{docker_port}"
    end

    desc 'spec', 'Run all of the specs against a running container'
    def spec
      image = create_image(image_name, dev_tag, options)
      run_tests(image, options)
    end

    desc 'ci', 'Builds the image, tests it and if tests pass it publishes to a docker registry'
    def ci
      bump_version
      create_image(repository_name, current_version, options) do |image|
        run_tests(image, options)
        publish_image(image, [current_version, 'latest'], options)
      end
    end

    private

    def bump_version
      invoke 'version:bump', [:auto], :default => :patch
    end

    def run_tests(image, opts)
      create_container(image, opts) do |container|
        port = container.mapped_port_for(22)

        wait_for_container(docker_host, port)

        Thocker.ui.banner "Running all the tests..."

        ENV['DOCKER_SSH_PORT'] = port
        ENV['DOCKER_SSH_KEY'] = dev_key
        ENV['DOCKER_HOST'] = docker_host
        Rake::Task["spec"].execute
      end
    end

    def wait_for_container(hostname, port)
      Thocker.ui.banner("Waiting for #{hostname}:#{port}...", :yellow) until host_available?(hostname, port)
    end

    def current_version
      ::ThorSCMVersion.versioner.from_path
    end

    def image_name
      Thocker.config.image.name
    end

    def registry
      Thocker.config.docker.registry.url
    end

    def docker_host
      Thocker.config.docker.host
    end

    def docker_port
      Thocker.config.docker.port
    end

    def dev_tag
      "#{`hostname -s`.strip}-dev"
    end

    def repository_name
      "#{registry}/#{image_name}"
    end

    #
    # The devolpment key for running serverspec tests over SSH.
    #
    def dev_key
      if key_file = Thocker.config.container.ssh_key_file
        File.read(key_file)
      else
        Thocker.config.container.ssh_key
      end
    end
  end
end
