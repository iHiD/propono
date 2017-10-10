module Propono
  class Logger

    StdLevels = %W{debug info warn}
    ErrorLevels = %W{error fatal}

    StdLevels.each do |level|
      define_method level do |*args|
        $stdout.puts(*args)
      end
    end

    ErrorLevels.each do |level|
      define_method level do |*args|
        $stderr.puts(*args)
      end
    end
  end
end
