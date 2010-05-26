#    RTiDI is a Ruby Tiny Dependency Injection library.
#    Copyright (C) 2010  Dmitrii Toksaitov
#
#    This file is part of RTiDI.
#
#    Released under the MIT License.

module DI

  # A hash for DI containers that is maintained and can be accessed
  #   with the +Kernel#di+ method
  #
  # @since 0.0.1
  CONTAINERS = {}

end

class File

  # Tries to create a directory silently
  #
  # This method is useful for maintenance of the application
  #   directories in the DI container
  #
  # Further in the example an asset is defined that creates an _.apprc_
  #   directory ONLY when accessed for the first time. If the directory
  #   was created successfully, the asset will be further returning the
  #   expanded directory path. If the directory was NOT created successfully,
  #   the asset will be further returning the nil value.
  #
  # @example Directory asset
  #   di :app_directories do
  #     asset :user_rc_dir do
  #       File.prepare_directory('~/.apprc')
  #     end
  #   end
  #
  # @param [String] path a directory path
  #   (will be expanded before creation)
  #
  # @return [String, nil] an expanded path of the created
  #   directory on success or nil if the directory does not exist
  #
  # @since 0.0.1
  def self.prepare_directory(path)
    path = File.expand_path(path)
    Dir.mkdir(path) rescue nil

    path if File.directory?(path)
  end

end

class String

  # A shortcut for the +File#join+ call
  #
  # Convenient in the containers concerned with a directory maintenance
  #
  # @example Usage of a proper system path separator
  #   di :app_directories do
  #     asset :user_specs_dir do
  #       File.prepare_directory('~' / '.apprc' / 'specs')
  #     end
  #   end
  #
  # @param [String] file a file or a directory string
  # @param [<String>] other file or directory strings
  #
  # @return [String] Returns a new string formed by joining the strings using
  #
  # @since 0.0.1
  def /(file, *other)
    File.join(self, file, *other)
  end

end

module Kernel

  # Calls +Kernel#require+ for all specified items
  #
  # Can be useful in service initialization blocks
  #
  # @example Service for all standard library extensions
  #   di :app_services do
  #     service :stdlib_extensions do
  #       require_all Dir['ext/**/*.rb']
  #     end
  #   end
  #
  # @param [String] item a file or a library to pass to the +Kernel#require+
  # @param [<String>] other files or libraries to pass to the +Kernel#require+
  #
  # @return [nil]
  #
  # @since 0.0.1
  def require_all(item, *other)
    [item, *other].each { |file| require(file) }
  end

  # Used to access a certain named DI container from
  # the +DI::CONTAINERS+ hash or to create a new container
  # instance if a container initialization blocks is given.
  #
  # @overload di(name = nil, &block)
  #   Creates a new DI container instance with the provided code block and adds
  #   it to the +DI::CONTAINERS+ hash if the name for the container was given
  #
  #   @example Creation of a DI container with the +Kernel#di+ shortcut
  #     di :my_web_app_services do
  #       service :views_processor do
  #         on_creation do
  #           require 'haml'; Haml
  #         end
  #
  #         interface :render do |instance, markup_text|
  #           instance::Engine.new(markup_text).render()
  #         end
  #       end
  #     end
  #
  #   $param [#hash, nil] name a name of the container that will be used to
  #     store it in the +DI::CONTAINERS+ hash. A new container will be created
  #     but will not be added to the +DI::CONTAINERS+ hash if the name was not
  #     provided (name is nil).
  #
  #   @param [Proc] block a block used to add services or assets
  #     to the current container instance
  #
  #   @yield [] evaluates a block in the context of the current
  #     container in order to present a convenient way to specify
  #     services and assets in it
  #
  #   @return [DI::Container] a newly created DI container
  #
  # @overload di(name = nil)
  #   Tries to get a DI container from the +DI::CONTAINERS+ hash with the
  #   given name or returns a +DI::CONTAINER+ hash itself if the name was
  #   not given
  #
  #   @example Accessing the +:my_web_app_services+ container defined previously
  #     container = di(:my_web_app_service)[:views_processor]
  #     container.render('%p Haml code!')
  #
  #   @param [#hash, nil] name a name of the container to get from the
  #     +DI::CONTAINERS+ hash. If the name was not given (name is nil), the
  #     +DI::CONTAINERS+ hash will be returned (if you want to use a +Hash#[]+
  #     method)
  #
  #   @return [DI::Container, nil, Hash] a container instance from the hash or
  #     the nil value if the container was not found with the given name. If the
  #     name was not provided, the +DI::CONTAINERS+ hash will be returned.
  #
  # @see DI::CONTAINERS
  #
  # @since 0.0.1
  def di(name = nil, &block)
    if block_given?
      result = DI::Container.new(&block)
      DI::CONTAINERS[name] = result if name

      result
    else
      DI::CONTAINERS[name]
    end
  end

end
