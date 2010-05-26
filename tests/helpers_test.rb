require File.join(File.expand_path(File.dirname(__FILE__)), 'helpers')

class HelpersTest < Test::Unit::TestCase

  def test_prepare_directory
    require 'tmpdir'
    dir = File.join(Dir::tmpdir, 'rtidi_test_dir')

    File.prepare_directory(dir)

    assert(File.directory?(dir))
    assert_equal(File.prepare_directory(dir), File.expand_path(dir))

    dir = File.join(dir, 'second_level', 'third_level')
    assert_nil(File.prepare_directory(dir))
  end

  def test_file_join_shortcut
    assert_equal('~' / 'dir', File.join('~', 'dir'))
    assert_equal('~' / 'dir' / 'dir', File.join('~', 'dir', 'dir'))
    assert_equal('~'./('dir', 'dir'), File.join('~', 'dir', 'dir'))

    assert_raise(TypeError) { '~' / 'dir' / nil }
  end

  def test_require_all
    require_all 'ostruct'
    require_all 'rational', 'matrix'

    assert(defined? OpenStruct)
    assert(defined? Rational)
    assert(defined? Matrix)
  end

  def test_di_shortcut
    di :services do
      service :view_processor do
        on_creation do
          require 'erb'; ERB
        end

        interface :render do |instance, markup_text|
          instance.new(markup_text).result()
        end
      end
    end

    assert_instance_of(DI::Container, di(:services))

    assert(di(:services)[:view_processor].respond_to?(:render))

    DI::CONTAINERS.clear()

    service = di do
      asset :app_rc_dir do
        '~' / '.apprc'
      end
    end

    assert(DI::CONTAINERS.empty?)

    assert_instance_of(DI::Container, service)
    assert_instance_of(String, service[:app_rc_dir])

    assert_equal(File.join('~', '.apprc'), service[:app_rc_dir])
  end

end
