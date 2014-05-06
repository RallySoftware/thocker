module Docker
  class Container
    def mapped_port_for(port)
      json['NetworkSettings']['Ports']["#{port}/tcp"][0]['HostPort']
    end
  end
end
