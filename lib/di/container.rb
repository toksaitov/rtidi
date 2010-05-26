#    RTiDI is a Ruby Tiny Dependency Injection library.
#    Copyright (C) 2010  Dmitrii Toksaitov
#
#    This file is part of RTiDI.
#
#    Released under the MIT License.

require 'yaml'

require 'di/helpers'

require 'di/proxy'
require 'di/service'

module DI

  # A tiny representation of the DI container
  #
  # @since 0.0.1
  #
  # @version 0.0.1
  class Container
    # List of services defined for the current container instance
    #
    # @return [<DI::Service>] a list of services
    #
    # @since 0.0.1
    attr_reader :services

    # Creates a new DI container.
    #
    # @param [Proc] block a block used to add services or assets
    #   to the current container instance
    #
    # @yield [] evaluates a block in the context of the current
    #   container in order to present a convenient way to specify
    #   services and assets in it
    #
    # @since 0.0.1
    def initialize(&block)
      @services = {}
      @current_service = nil

      instance_eval(&block) if block_given?
    end

    # Specifies a service for the container with a given code block
    #
    # The context of the container is set to the given service name
    # and the block is evaluated in the context of the current
    # container instance
    #
    # @param [#hash] name a service name
    # @param [Proc] a block used to specify interfaces and
    #   initialization logic for the service
    #
    # @yield [] Evaluates a block in the context of the current
    #   container in order to present a convenient way to specify
    #   interfaces and initialization logic for the newly defined service
    #
    # @since 0.0.1
    def service(name, &block)
      @current_service = name

      instance_eval(&block) if block_given?

      @current_service = nil
    end

    # Specifies an asset for the current container instance
    #
    # The difference between an asset and a service is that an asset
    # could not contain interfaces. An asset can store a specific objects
    # instance or an initialization block that will be called once when
    # the asset is accessed. The object received from the initialization
    # block will be stored and returned on all future access requests
    # unless an +:init+ option was passed with the access request.
    # On the other hand, these limitations make it possible to serialize
    # assets.
    #
    # @param [Hash] options an options hash for the asset
    # @option options [String] :file ('nil') a file path specifying
    #   a location and a file name to where to serialize an initialized
    #   instance of the asset and from where to load and deserialize
    #   an already initialized one. The serialization/deserialization
    #   logic will not be used if the +:file+ option was not
    #   given (equals to nil).
    #
    # @param [Proc] block a block that will be used to initialize an asset
    #   when called for the first time
    #
    # @overload asset(arg, options, &block)
    #   Creates an asset with a specified object defined in a hash unless
    #   a block is given
    #
    #   @example Containers to store translations for specific locales
    #     di :un_US do
    #       asset :welcome_message => 'Hello, world!'
    #     end
    #
    #     di :ru_RU do
    #       asset :welcome_message => 'Привет, Мир!'
    #     end
    #
    #   @param [Hash] arg a hash where an initialized instance and
    #     an asset name is given (e. g. +:asset_name => instance+)
    #
    # @overload asset(arg, options, &block)
    #   Creates an asset with a specified initialization block
    #
    #   @example Containers to set up application directories
    #     di :app_dirs do
    #       asset :user_dir do
    #         File.prepare_directory('~' / '.apprc')
    #       end
    #
    #       asset :user_logs do
    #         File.prepare_directory(di(:app_dirs)[:user_dir] / '.apprc')
    #       end
    #     end
    #
    #   @param [#hash] arg a name of the new asset
    #
    # @since 0.0.1
    def asset(arg, options = {}, &block)
      if arg.is_a?(Hash)
        name, instance = arg.to_a().first
      else
        name, instance = arg, nil
      end

      if path = options[:file]
        instance = (YAML.load_file(path) rescue nil) || instance
      end

      if instance or block_given?
        service = find_service(name)

        service[:block]    = block
        service[:instance] = instance
        service[:file]     = path
      end
    end

    def [](name, option = nil)
      result = nil

      if service = @services[name.to_s().to_sym()]
        if not service[:initialized] or option == :init
          if instance = service[:block].call()
            result = service[:instance] =
              Proxy.new(instance, service[:interfaces])
          end
        else
          result = service[:instance]
        end
      end

      if option == :raw
        result.delegate() if result.respond_to? :delegate
      else
        result
      end
    end

    def update(arg, file = nil)
      services = if arg.is_a?(Symbol)
        if arg == :all
          file = nil; @services.values
        else
          [find_service(arg.to_s().to_sym())]
        end
      else
        arg.is_a?(Array) ? arg : [arg]
      end

      services.each do |service|
        serialize(service, file) if service
      end
    end

    private
    def on_creation(&block)
      asset(@current_service, &block)
    end

    def interface(args, service_name = @current_service, &block)
      if block_given?
        args = [args] unless args.is_a?(Array)

        args.each do |name|
          service = find_service(service_name)
          service[:interfaces][name.to_s().to_sym()] = block if service
        end
      end
    end

    def serialize(service, file = nil)
      path = file || service[:file]
      instance = service[:instance]

      if path and instance
        begin
          File.open(path, 'w+') do |io|
            io.write(instance.to_yaml())
          end
        rescue Exception => e
          puts("DI container failed to serialize service to #{path}")
          puts(e.message, e.backtrace)
        end
      end
    end

    def find_service(name)
      result = nil

      if name
        name = name.to_s().to_sym()

        unless result = @services[name]
          new_service = Service.new()
          new_service.add_observer(self)

          result = @services[name] = new_service
        end
      end

      result
    end
  end

end
