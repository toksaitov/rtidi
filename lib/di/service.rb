#    RTiDI is a Ruby Tiny Dependency Injection library.
#    Copyright (C) 2010  Dmitrii Toksaitov
#
#    This file is part of RTiDI.
#
#    Released under the MIT License.

require 'observer'

module DI

  # An encapsulation of a service definition
  #
  # Used to store:
  # * an initialization block
  # * 
  class Service
    include Observable

    attr_reader :definition

    def initialize(definition = {:block      => nil,
                                 :instance   => nil,
                                 :interfaces => {},
                                 :file       => nil})

      @definition = definition; state_update()
    end

    def [](key)
      @definition[key]
    end

    def []=(key, value)
      previous_value, @definition[key] = @definition[key], value
      state_update() if previous_value != value

      value
    end

    def nil?
      @definition.nil?
    end

    private
    def state_update
      changed(); notify_observers(@definition)
    end
  end

end

