require 'test/unit'
require 'stringio'

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', 'rtidi'))

module Kernel

  def fake_stdout(stdout = StringIO.new())
    $stdout = stdout
    yield if block_given?

    return stdout
  ensure
    $stdout = STDOUT
  end

  def fake_stderr(stderr = StringIO.new())
    $stderr = stderr
    yield if block_given?

    return stderr
  ensure
    $stderr = STDERR
  end

end
