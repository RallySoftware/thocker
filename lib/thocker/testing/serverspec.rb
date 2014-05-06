require 'serverspec'
require 'net/ssh'

include SpecInfra::Helper::Ssh

RSpec.configure do |c|
  c.before :all do
    host = ENV['DOCKER_HOST']
    if c.host != host
      c.ssh.close if c.ssh
      c.host  = host
      options = Net::SSH::Config.for(c.host)
      options[:key_data] = [ENV['DOCKER_SSH_KEY']]
      options[:user] = 'root'
      options[:port] = ENV['DOCKER_SSH_PORT'] || 22
      puts options.inspect
      c.ssh = Net::SSH.start(c.host, options[:user], options)
    end
  end
end
