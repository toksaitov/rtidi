require File.join(File.expand_path(File.dirname(__FILE__)), 'helpers')

class ContainerTest < Test::Unit::TestCase

  def test_container_service
    string_io = StringIO.new()

    di :sample do
      service :logger do
        on_creation do
          require 'logger'

          logger = Logger.new(string_io)
          logger.level = Logger::INFO

          logger
        end

        interface [:info, :puts, :write, :<<] do |instance, message|
          message = message.inspect.strip()
          instance.info(message)
        end

        interface :flush do |instance| end
      end
    end

    assert_instance_of(DI::Container, di(:sample))

    logger = DI::CONTAINERS[:sample][:logger]
    assert_instance_of(Logger, logger)

    [:info, :puts, :write, :<<, :flush].each do |method|
      assert(di(:sample)[:logger].respond_to?(method))
    end
  end

  def test_container_asset
    di :directories do
      asset :app_temp_dir do
        File.prepare_directory(Dir::tmpdir / 'rtdi')
      end
    end
  end

end
