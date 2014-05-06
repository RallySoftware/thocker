require 'thor'
require 'docker'
require 'rspec/core/rake_task'
require 'thor/rake_compat'
require 'thor/scmversion'
require 'thocker/mixin/shell_out'
require 'thocker/mixin/docker'
require 'thocker/mixin/net'
require 'thocker/ext/container'

module Thocker
  autoload :Config, 'thocker/config'
  autoload :Shell, 'thocker/shell'

  class << self
    include Thocker::Mixin::ShellOut

    def ui
      @ui ||= Thocker::Shell.new
    end

    def config
      @config ||= Thocker::Config.instance
    end

    def image_name
      "rally/#{/(?:docker-)?(.*)/.match(File.basename(project_path))[1]}"
    end

    def project_path
      File.dirname(config_file)
    end

    def config_file
      find_file(Dir.pwd, '.thocker') || raise("Config file .thocker not found.")
    end

    private

    def find_file(current_dir, file)
      return File.expand_path(file) if File.exist?(file)
      Dir.chdir('..') do
        return nil if Dir.pwd == current_dir
        find_file(Dir.pwd, file)
      end
    end
  end
end
