require 'test_helper'

class MiniDztTest < Minitest::Test
  def setup
    @sample_img1 = File.join File.expand_path('../fixtures', __FILE__), "img1.jpg"
    @output_dir = File.expand_path('../tmp', __FILE__)
  end

  def test_main
    image = MiniMagick::Image.open @sample_img1
    tiler = MiniDzt::Tiler.new(source: @sample_img1)

    max_level = tiler.send(:max_level, image.width, image.height)
    manuscripts = tiler.send(:get_manuscripts, image.width, image.height, "/test")

    tiler.slice!(@output_dir)

    assert_equal 13, max_level
    assert_equal(
      [
        ["/test/0_0.jpg", "512x512+0+0"],
        ["/test/0_1.jpg", "512x512+512+0"],
        ["/test/0_2.jpg", "512x512+1024+0"],
        ["/test/0_3.jpg", "512x512+1536+0"],
        ["/test/1_0.jpg", "512x512+0+512"],
        ["/test/1_1.jpg", "512x512+512+512"],
        ["/test/1_2.jpg", "512x512+1024+512"],
        ["/test/1_3.jpg", "512x512+1536+512"],
        ["/test/2_0.jpg", "512x512+0+1024"],
        ["/test/2_1.jpg", "512x512+512+1024"],
        ["/test/2_2.jpg", "512x512+1024+1024"],
        ["/test/2_3.jpg", "512x512+1536+1024"],
        ["/test/3_0.jpg", "512x512+0+1536"],
        ["/test/3_1.jpg", "512x512+512+1536"],
        ["/test/3_2.jpg", "512x512+1024+1536"],
        ["/test/3_3.jpg", "512x512+1536+1536"],
        ["/test/4_0.jpg", "512x512+0+2048"],
        ["/test/4_1.jpg", "512x512+512+2048"],
        ["/test/4_2.jpg", "512x512+1024+2048"],
        ["/test/4_3.jpg", "512x512+1536+2048"],
        ["/test/5_0.jpg", "512x512+0+2560"],
        ["/test/5_1.jpg", "512x512+512+2560"],
        ["/test/5_2.jpg", "512x512+1024+2560"],
        ["/test/5_3.jpg", "512x512+1536+2560"],
        ["/test/6_0.jpg", "512x512+0+3072"],
        ["/test/6_1.jpg", "512x512+512+3072"],
        ["/test/6_2.jpg", "512x512+1024+3072"],
        ["/test/6_3.jpg", "512x512+1536+3072"],
        ["/test/7_0.jpg", "512x512+0+3584"],
        ["/test/7_1.jpg", "512x512+512+3584"],
        ["/test/7_2.jpg", "512x512+1024+3584"],
        ["/test/7_3.jpg", "512x512+1536+3584"],
        ["/test/8_0.jpg", "512x512+0+4096"],
        ["/test/8_1.jpg", "512x512+512+4096"],
        ["/test/8_2.jpg", "512x512+1024+4096"],
        ["/test/8_3.jpg", "512x512+1536+4096"]
      ], manuscripts
    )
    assert_equal 14, Dir.glob(@output_dir + "/*").count
    assert_equal 61, Dir.glob(@output_dir + "/*/**").count
    FileUtils.rm_rf(@output_dir)
  end
end
