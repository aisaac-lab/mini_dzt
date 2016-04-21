require 'test_helper'

class MiniDztTest < Minitest::Test
  def setup
    @sample_img1 = File.join File.expand_path('../fixtures', __FILE__), "img1.jpg"
    @sample_img2 = File.join File.expand_path('../fixtures', __FILE__), "img2.jpg"
    @output_dir = File.expand_path('../tmp', __FILE__)
    @binary = File.expand_path('../../exe/mini_dzt', __FILE__)

    @image1 = MiniMagick::Image.open @sample_img1
    @tiler1 = MiniDzt::Tiler.new(source: @sample_img1)
  end

  def test_exec
    `#{@binary} #{@sample_img1} #{@output_dir}`
    assert_equal 14, Dir.glob(@output_dir + "/*").count
    assert_equal 61, Dir.glob(@output_dir + "/*/**").count

    FileUtils.rm_rf(@output_dir)
  end

  def test_tile_counts
    assert_equal 9, @tiler1.send(:tile_counts, @image1.width)
    assert_equal 4, @tiler1.send(:tile_counts, @image1.height)
  end

  def test_max_level
    assert_equal 13, @tiler1.send(:max_level, @image1.width, @image1.height)
  end

  def test_get_manuscripts
    assert_equal(
      [
        ["/test/0_0.jpg", "512x512+0+0"],
        ["/test/1_0.jpg", "512x512+512+0"],
        ["/test/2_0.jpg", "512x512+1024+0"],
        ["/test/3_0.jpg", "512x512+1536+0"],
        ["/test/4_0.jpg", "512x512+2048+0"],
        ["/test/5_0.jpg", "512x512+2560+0"],
        ["/test/6_0.jpg", "512x512+3072+0"],
        ["/test/7_0.jpg", "512x512+3584+0"],
        ["/test/8_0.jpg", "512x512+4096+0"],
        ["/test/0_1.jpg", "512x512+0+512"],
        ["/test/1_1.jpg", "512x512+512+512"],
        ["/test/2_1.jpg", "512x512+1024+512"],
        ["/test/3_1.jpg", "512x512+1536+512"],
        ["/test/4_1.jpg", "512x512+2048+512"],
        ["/test/5_1.jpg", "512x512+2560+512"],
        ["/test/6_1.jpg", "512x512+3072+512"],
        ["/test/7_1.jpg", "512x512+3584+512"],
        ["/test/8_1.jpg", "512x512+4096+512"],
        ["/test/0_2.jpg", "512x512+0+1024"],
        ["/test/1_2.jpg", "512x512+512+1024"],
        ["/test/2_2.jpg", "512x512+1024+1024"],
        ["/test/3_2.jpg", "512x512+1536+1024"],
        ["/test/4_2.jpg", "512x512+2048+1024"],
        ["/test/5_2.jpg", "512x512+2560+1024"],
        ["/test/6_2.jpg", "512x512+3072+1024"],
        ["/test/7_2.jpg", "512x512+3584+1024"],
        ["/test/8_2.jpg", "512x512+4096+1024"],
        ["/test/0_3.jpg", "512x512+0+1536"],
        ["/test/1_3.jpg", "512x512+512+1536"],
        ["/test/2_3.jpg", "512x512+1024+1536"],
        ["/test/3_3.jpg", "512x512+1536+1536"],
        ["/test/4_3.jpg", "512x512+2048+1536"],
        ["/test/5_3.jpg", "512x512+2560+1536"],
        ["/test/6_3.jpg", "512x512+3072+1536"],
        ["/test/7_3.jpg", "512x512+3584+1536"],
        ["/test/8_3.jpg", "512x512+4096+1536"]
      ], @tiler1.send(:get_manuscripts, @image1.width, @image1.height, "/test")
    )
  end

  def test_slice!
    @tiler1.slice!(@output_dir)
    assert_equal 14, Dir.glob(@output_dir + "/*").count
    assert_equal 61, Dir.glob(@output_dir + "/*/**").count
    Dir.glob(@output_dir + "/13/**").each do |img_path|
      img = MiniMagick::Image.open img_path
      assert(img.width > 200)
      assert(img.height > 400)
    end

    FileUtils.rm_rf(@output_dir)
  end

  # def test_img2
  #   tiler = MiniDzt::Tiler.new(source: @sample_img2)
  #
  #   tiler.slice!(@output_dir)
  #   assert_equal 14, Dir.glob(@output_dir + "/*").count
  #   assert_equal 61, Dir.glob(@output_dir + "/*/**").count
  # end
end
