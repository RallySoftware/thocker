# Thocker

Thocker provides an environment for developing and publishing docker images to a private registry.

## Installation

Add this line to your application's Gemfile:

    gem 'thocker', :github => 'RallySoftware/thocker'

And then execute:

    $ bundle

## Usage

Create a Thorfile in your docker image's git repository and add

```ruby
require 'thocker/thor/tasks'
```

Create a spec directory for your tests and add a `spec_helper.rb` with the contents

```ruby
require 'thocker/testing/serverspec'
```

In each of your spec files make sure to `require 'spec_helper'`.

## Testing

For thocker to run tests it does the following:

1. Creates an image by building the `Dockerfile`.
2. Creates a container from this image, specifying a volume on the container to `/root/.ssh`
3. Starts the container and binds `/root/docker-ssh-keys` on the docker host to `/root/.ssh` on the
container
4. It then determines the port on the docker host where the container's port 22 is mapped. It provides this
information to serverspec. It also provides the ssh private key that is provided in the `.thocker` config
file.
5. With the hostname, port and private key serverspec has what it needs to run test via SSH.
6. Once the tests are finished the container is killed and destroyed.
7. If testing was initiated via the `ci` task the image is destroyed after the container.

### Assumptions

1. Your docker host has a directory `/root/docker-ssh-keys`. In this directory is an authorized_keys file
that has the public key corresponding to the private key given in the `.thocker` config.
2. Your `Dockerfile` exposes port `22`.

## Config

The root of your project should contain a `.thocker` file containing project specific configuration.
This file is a ruby file and can contain arbitrary code.

Available options:
* `image[:name]` - The name of the image. Required.
* `docker[:host]` - The hostname of the host where the docker daemon is running. Required.
* `docker[:port]` - The port where the docker daemon is running. Defaults to `4243`.
* `docker[:registry][:url]` - The private registry to publish to. This should be in the form
of hostname:port. Required.
* `container[:ssh_key]` - The ssh private key to be used for testing. Should be set if the ssh_key_file is not.
* `container[:ssh_key_file]` - The ssh private key file to be used for testing. Should be set if the ssh_key is not.

## Tasks
* `thor spec` - Builds the image, creates and starts the container and runs the tests.
The container is killed and removed after each run, however the image is not. After running
the `spec` task and issuing a `docker images` command you will see your image tagged with
`<hostname>-dev`. It's not a bad idea to do a `docker rmi` on this image when your
development work is complete.

* `thor ci` - Bumps the version, builds the image, creates and starts the container, and runs the tests. If the tests are successful the image is uploaded to the private registry and tagged with both the current version
and 'latest' tags.

## Contributing

1. Fork it ( http://github.com/<my-github-username>/docker-development/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
