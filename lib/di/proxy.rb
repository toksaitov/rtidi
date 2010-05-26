#    RTiDI is a Ruby Tiny Dependency Injection library.
#    Copyright (C) 2010  Dmitrii Toksaitov
#
#    This file is part of RTiDI.
#
#    Released under the MIT License.

module DI

  # A simple proxy pattern implementation to hold services or assets defined in
  # DI container instances
  #
  # By default all services are returned in a proxy wrapper that is created
  # as an instance of this class. This wrapper allows to handle additional
  # operations for instances that were defined with the +interface+ method
  # of the +DI::Container+ class.
  #
  # A proxy instance tries to route method calls in the following order:
  # 1. to defined interfaces for the wrapped object
  # 2. to actual methods of the wrapped object
  #
  # A proxy object tries to imitate the wrapped object as mach as possible
  #
  # @since 0.0.1
  #
  # @version 0.0.1
  class Proxy
    instance_methods.each do |method|
      undef_method(method) unless method =~ /(^__|^send$|^object_id$)/
    end

    # Provides access to the wrapped object
    #
    # @return [Object] the wrapped object
    #
    # @since 0.0.1
    attr_reader :delegate

    # Provides access to the hash of interfaces defined
    # for the wrapped object
    #
    # @return [{Symbol, Proc}] the hash of interfaces
    #
    # @since 0.0.1
    attr_reader :interfaces

    # Initializes a new proxy instance with an object and a hash of
    # additional interfaces (defaults to an empty hash)
    #
    # @param [Object] delegate an object that will be wrapped by the
    #   proxy instance
    #
    # @param [{Symbol, Proc}] interfaces a hash of additional interfaces for
    #   the wrapped object
    #
    # @since 0.0.1
    def initialize(delegate, interfaces = {})
      @delegate   = delegate
      @interfaces = interfaces
    end

    # Checks if the wrapped object responds to the given method or to the
    # given interface (from the hash of interfaces)
    #
    # Private methods are included in the search only if the
    # optional second parameter evaluates to true.
    #
    # @param [Symbol] symbol a symbol that represents the name of the method
    #   or interface
    #
    # @param [Boolean] include_private a specification whether to include
    #   private methods in the search or not
    #
    # @return [Boolean] a status whether the wrapped object responds to the
    #   specified method
    #
    # @since 0.0.1
    def respond_to?(symbol, include_private=false)
      @interfaces.has_key?(symbol) ||
      @delegate.respond_to?(symbol, include_private)
    end

    private
    def method_missing(name, *args, &block)
      if interface = @interfaces[name.to_s().to_sym()]
        interface.call(@delegate, *args, &block)
      else
        @delegate.__send__(name, *args, &block)
      end
    end
  end

end
