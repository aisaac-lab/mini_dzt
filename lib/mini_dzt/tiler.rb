require 'mini_magick'

module MiniDzt
  class Tiler
    # Defaults
    DEFAULT_TILE_SIZE = 512
    DEFAULT_TILE_OVERLAP = 0
    DEFAULT_QUALITY = 75
    DEFAULT_TILE_FORMAT = 'jpg'
    DEFAULT_OVERWRITE_FLAG = false

    # Generates the DZI-formatted tiles and sets necessary metadata on this object.
    #
    # @param [Hash] options
    # @option source Magick::Image, or filename of image to be used for tiling
    # @option quality Image compression quality (default: 75)
    # @option format Format for output tiles (default: "jpg")
    # @option size Size, in pixels, for tile squares (default: 512)
    # @option overlap Size, in pixels, of the overlap between tiles (default: 2)
    # @option overwrite Whether or not to overwrite if the destination exists (default: false)
    # @option storage Either an instance of S3Storage or FileStorage
    def initialize(options)
      fail 'Missing options[:source].' unless options[:source]

      @tile_source  = MiniMagick::Image.open(options[:source])
      @tile_size    = options[:size] || DEFAULT_TILE_SIZE
      @tile_overlap = options[:overlap] || DEFAULT_TILE_OVERLAP
      @tile_format  = options[:format] || DEFAULT_TILE_FORMAT
      @tile_quality = options[:quality] || DEFAULT_QUALITY
      @overwrite    = options[:overwrite] || DEFAULT_OVERWRITE_FLAG
      @storage      = options[:storage]

      @max_tiled_height = @tile_source.height
      @max_tiled_width = @tile_source.width
    end

    def slice!
      @tmp_working_dir = Pathname(@tile_source.path).dirname + "mini_dzt_#{SecureRandom.hex}"
      FileUtils.mkdir_p @tmp_working_dir

      orig_width = @tile_source.width
      orig_height = @tile_source.height

      max_level(orig_width, orig_height).downto(0) do |level|
        current_level_storage_dir = "#{@tmp_working_dir}/#{level}"
        FileUtils.mkdir_p current_level_storage_dir

        width = @tile_source.height
        height = @tile_source.width

        manuscripts = get_manuscripts(width, height, current_level_storage_dir)

        manuscripts.each do |dest_path, geometry_arg|
          crope_image(@tile_source, dest_path, geometry_arg, @tile_quality)
        end

        @tile_source.resize("50%")
      end
    end

    private
      def get_manuscripts(width, height, current_level_storage_dir)
        manuscripts = []
        x = 0
        col_count = 0
        while x < width
          y = 0
          row_count = 0
          while y < height
            tile_width, tile_height = tile_dimensions(x, y, @tile_size, @tile_overlap)
            manuscripts << [
              File.join(current_level_storage_dir, "#{col_count}_#{row_count}.#{@tile_format}"),
              "#{tile_width}x#{tile_height}+#{y}+#{x}"
            ]
            y += (tile_height - (2 * @tile_overlap))
            row_count += 1
          end
          x += (tile_width - (2 * @tile_overlap))
          col_count += 1
        end
        manuscripts
      end

      def tile_dimensions(x, y, tile_size, overlap)
        overlapping_tile_size = tile_size + (2 * overlap)
        border_tile_size      = tile_size + overlap

        tile_width  = (x > 0) ? overlapping_tile_size : border_tile_size
        tile_height = (y > 0) ? overlapping_tile_size : border_tile_size

        [tile_width, tile_height]
      end

      def max_level(width, height)
        (Math.log([width, height].max) / Math.log(2)).ceil
      end

      def crope_image(image, dest_path, geometry_arg, quality = 75)
        `convert -crop #{geometry_arg} #{image.path} #{dest_path}`
      end
  end
end
