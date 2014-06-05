require 'thocker'
require 'rspec/core'
require 'serverspec'
require 'net/ssh'

#
# Project tasks. These tasks are intended to be included from a project's
# Thorfile.
module Thocker
  class Tasks < Thor
    include Thor::RakeCompat
    include Thocker::Mixin::ShellOut
    include Thocker::Mixin::DockerAPI
    include Thocker::Mixin::Net

    namespace :default

    def initialize(*args)
      super
      Docker.url = "tcp://#{docker_host}:#{docker_port}"
      Docker.options = { :read_timeout => 300 }
    end

    method_option :destroy,
      type: :boolean,
      default: true,
      desc: 'Destroy the container after running the tests.'
    method_option :cache,
      type: :boolean,
      default: true,
      desc: 'Use the cache when building the image.'
    desc 'spec', 'Run all of the specs against a running container'
    def spec
      image = create_image(image_name, dev_tag, options)
      run_tests(image, options)
    end

    desc 'ci', 'Builds the image, tests it and if tests pass it publishes to a docker registry'
    def ci
      opts = options.merge({
        destroy: true,
        cache: false})

      bump_version
      create_image(repository_name, current_version, opts) do |image|
        run_tests(image, opts)
        tag_image(image, repository_name, 'latest')
        publish_image(image, ['latest', current_version], opts)
      end
    end

    private

    def bump_version
      invoke 'version:bump', [:auto], :default => :patch
    end

    def run_tests(image, opts)
      create_container(image, opts) do |container|
        ssh_port = container.mapped_port_for(22)

        wait_for_container(docker_host, ssh_port)

        Thocker.ui.banner "Running all the tests..."

        prepare_rspec(container, ssh_port)
        RSpec::Core::Runner.run(['spec'])
      end
    end

    #
    # Get ready to run rspec tests.
    # - Add settings to the RSpec config object which contain
    #   docker/container specific information
    # - Setup serverspec by configurting net/ssh
    def prepare_rspec(container, ssh_port)
      add_rspec_settings(container, ssh_port)
      setup_serverspec
    end

    #
    # Pass along container information so that
    # rspec tests have access to it.
    def add_rspec_settings(container, ssh_port)
      RSpec.configure do |c|
        c.add_setting :docker_ports
        c.docker_ports = container.ports
        c.add_setting :docker_host
        c.docker_host = docker_host
        c.add_setting :dev_key
        c.dev_key = dev_key
        c.add_setting :ssh_port
        c.ssh_port = ssh_port
      end
    end

    #
    # Configure serverspec by setting up net/ssh in
    # a before all.
    def setup_serverspec
      RSpec.configure do |c|
        c.before(:all) do
          if c.host != c.docker_host
            c.ssh.close if c.ssh
            c.host = c.docker_host
            options = Net::SSH::Config.for(c.host)
            options[:key_data] = [c.dev_key]
            options[:user] = 'root'
            options[:port] = c.ssh_port
            c.ssh = Net::SSH.start(c.host, options[:user], options)
          end
        end
      end
    end

    def wait_for_container(hostname, port)
      Thocker.ui.banner("Waiting for #{hostname}:#{port}...", :yellow) until host_available?(hostname, port)
    end

    def current_version
      ::ThorSCMVersion.versioner.from_path
    end

    def image_name
      Thocker.config.image[:name]
    end

    def registry
      Thocker.config.docker[:registry][:url]
    end

    def docker_host
      Thocker.config.docker[:host]
    end

    def docker_port
      Thocker.config.docker[:port]
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
