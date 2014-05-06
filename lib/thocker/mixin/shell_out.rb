require 'mixlib/shellout'

module Thocker
  module Mixin
    module ShellOut
     def shell_out(*command_args)
        cmd = Mixlib::ShellOut.new(*command_args)
        cmd.run_command
        cmd
      end

      def shell_out!(*command_args)
        cmd = shell_out(*command_args)
        cmd.error!
        cmd
      end
    end
  end
end
