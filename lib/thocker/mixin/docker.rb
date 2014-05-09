module Thocker
  module Mixin
    module DockerAPI
      #
      # Builds the docker image using the repository name given
      # If a block is provided then the image object returned from the
      # Docker API creation will be yielded to the block and then
      # after the yield the image will be deleted via the API.
      # In either case the image object is returned.
      def create_image(repository, tag, opts)
        Thocker.ui.banner "Creating image #{repository}"

        repo_and_tag = "#{repository}:#{tag}"
        build_opts = {'t' => repo_and_tag, 'rm' => true }
        build_opts['nocache'] = opts[:no_cache]
        image = Docker::Image.build_from_dir('.', build_opts) do |chunk|
          print_docker_response(chunk)
        end

        if block_given?
          begin
            yield image
          ensure
            Thocker.ui.banner "Removing image #{image.id}"
            print_docker_response(image.remove('force' => true))
          end
        end

        image
      end

      #
      # Creates a container from an image.
      # If a block is given then the container object is
      # yielded to the block and then the container is
      # stopped and removed afterwards.
      # The container object is returned.
      def create_container(image, opts)
        Thocker.ui.banner "Creating container..."
        container = Docker::Container.create({
          'Image' => image.id,
          'Volumes' => { '/root/.ssh' => {} }})

        Thocker.ui.banner "Starting container..."
        container = container.start({
          'PublishAllPorts' => true,
          'Binds' => ['/root/docker-ssh-keys:/root/.ssh']})

        if block_given?
          begin
            yield container
          ensure
            if opts[:destroy]
              Thocker.ui.banner "Removing container #{container.id}"
              container.stop
              container.remove
            else
              Thocker.ui.banner "Not removing #{container.id} by request of user."
            end

          end
        end

        container
      end

      def publish_image(image, tags, opts)
        Thocker.ui.banner "Publishing image..."
        image.refresh!

        tags.each do |tag|
          image.push(nil, tag: tag)
        end
      end

      private

      def print_parsed_response(response)
        case response
        when Hash
          response.each do |key, value|
            case key
            when 'stream'
              Thocker.ui.say value
            else
              Thocker.ui.say "#{key}: #{value}"
            end
          end
        when Array
          response.each do |hash|
            print_parsed_response(hash)
          end
        end
      end

      def print_docker_response(json)
        print_parsed_response(JSON.parse(json))
      end
    end
  end
end
