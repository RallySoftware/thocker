module Thocker
  Shell = Class.new(Thor::Base.shell) do
    def mute!
      @mute = true
    end

    def unmute!
      @mute = false
    end

    def say(*args)
      return if quiet?
      super(*args)
    end
    alias_method :info, :say

    def warn(message, color = :yellow)
      say(message, color)
    end

    def error(message, color = :red)
      message = set_color(message, *color) if color
      super(message)
    end

    def banner(message, color = :green)
      say("-----> #{message}", color)
    end
  end
end
