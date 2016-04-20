require 'test_helper'

class MiniDztTest < Minitest::Test
  def setup
    @fixtures_dir = File.expand_path('../fixtures', __FILE__)
  end

  def test_main
    tiler = MiniDzt::Tiler.new(source: File.join(@fixtures_dir, "img1.jpg"))
    tiler.slice!
  end
end
