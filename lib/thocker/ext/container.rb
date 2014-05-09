module Docker
  class Container
    def mapped_port_for(port)
      json['NetworkSettings']['Ports']["#{port}/tcp"][0]['HostPort']
    end

    def ports
      json['NetworkSettings']['Ports'].inject({}) do |port_map, (key, value)|
        ports = value.map { |p| p['HostPort'] }
        port_map[key.match(/(.*)\/tcp/).captures[0].to_i] = ports
        port_map
      end
    end
  end
end
