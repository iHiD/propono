require File.expand_path('../test_helper', __FILE__)

module Propono
  class LoggerTest < Minitest::Test
    def setup
      super
      @logger = Logger.new
    end

    def test_debug
      $stdout.expects(:puts).with("foobar")
      @logger.debug "foobar"
    end

    def test_info
      $stdout.expects(:puts).with("foobar")
      @logger.info "foobar"
    end

    def test_warn
      $stdout.expects(:puts).with("foobar")
      @logger.warn "foobar"
    end

    def test_error
      $stderr.expects(:puts).with("foobar")
      @logger.error "foobar"
    end

    def test_fatal
      $stderr.expects(:puts).with("foobar")
      @logger.fatal "foobar"
    end
  end
end
