require 'buff/config/ruby'

module Thocker
  class Config < Buff::Config::Ruby
    class << self
      # @return [String]
      def path
        File.join(Thocker.project_path.to_s, '.thocker')
      end

      # @return [String, nil]
      #   the contents of the file
      def file
        File.read(path) if File.exists?(path.to_s)
      end

      # Instantiate and return or just return the currently instantiated Docker Development
      # configuration
      #
      # @return [Config]
      def instance
        @instance ||= from_ruby(file)
      end

      # Reload the currently instantiated Docker Development configuration
      #
      # @return [Config]
      def reload
        @instance = nil
        self.instance
      end
    end

    # @param [String] path
    # @param [Hash] options
    #   @see {Buff::Config::JSON}
    def initialize(path = self.class.path, options = {})
      super(path, options)
    end

    attribute 'docker.host',
      type: String,
      required: true
    attribute 'docker.port',
      type: Fixnum,
      default: 4243
    attribute 'docker.registry.url',
      type: String,
      required: true
    attribute 'image.name',
      type: String,
      required: true
    attribute 'container.ssh_key',
      type: String
    attribute 'container.ssh_key_file',
      type: String
  end
end
