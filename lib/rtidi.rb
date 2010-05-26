#    RTiDI is a Ruby Tiny Dependency Injection library.
#    Copyright (C) 2010  Dmitrii Toksaitov
#
#    This file is part of RTiDI.
#
#    Released under the MIT License.

partial_path = File.dirname(__FILE__)
full_path    = File.expand_path(partial_path)

$LOAD_PATH.unshift(partial_path) unless $LOAD_PATH.include?(partial_path) or
                                        $LOAD_PATH.include?(full_path)

# The base namespace for the RTiDI library
#
# @since 0.0.1
module DI
  FULL_NAME = 'RTiDI'
  UNIX_NAME = 'rtidi'
  VERSION   = '0.0.1'

  AUTHOR = 'Toksaitov Dmitrii Alexandrovich'

  EMAIL = "toksaitov.d@gmail.com"
  URL   = "http://github.com/toksaitov/#{UNIX_NAME}/"

  COPYRIGHT = "Copyright (C) 2010 #{AUTHOR}"
end

require 'di/container'
