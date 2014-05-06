module Thocker
  module Mixin
    module Net
      #
      # Determine if the hostname@port is accepting TCP requests.
      #
      def host_available?(hostname, port)
        socket = TCPSocket.new(hostname, port)
        IO.select([socket], nil, nil, 5)
      rescue SocketError, Errno::ECONNREFUSED,
        Errno::EHOSTUNREACH, Errno::ENETUNREACH, IOError
        sleep 2
        false
      rescue Errno::EPERM, Errno::ETIMEDOUT
        false
      ensure
        socket && socket.close
      end

    end
  end
end
