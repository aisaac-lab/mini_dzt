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
    #
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

    ##
    # Generates the DZI-formatted tiles and sets necessary metadata on this object.
    # Uses a default tile size of 512 pixels, with a default overlap of 2 pixel.
    ##
    def slice!(&_block)
      binding.pry
      # fail "Output #{@destination} already exists!" if ! @overwrite && @storage.exists?

      image = @tile_source.dup
      orig_width = image.height
      orig_height = image.width

      # iterate over all levels (= zoom stages)
      max_level(orig_width, orig_height).downto(0) do |level|
        width = image.height
        height = image.width

        current_level_storage_dir = @storage.storage_location(level)
        @storage.mkdir(current_level_storage_dir)
        yield current_level_storage_dir if block_given?

        # iterate over columns
        x = 0
        col_count = 0
        while x < width
          # iterate over rows
          y = 0
          row_count = 0
          while y < height
            tile_width, tile_height = tile_dimensions(x, y, @tile_size, @tile_overlap)
            dest_path = File.join(current_level_storage_dir, "#{col_count}_#{row_count}.#{@tile_format}")

            save_cropped_image(image, dest_path, x, y, tile_width, tile_height, @tile_quality)

            y += (tile_height - (2 * @tile_overlap))
            row_count += 1
          end
          x += (tile_width - (2 * @tile_overlap))
          col_count += 1
        end

        image.resize("50%")
      end
    end
    #
    # protected
    #
    # # Determines width and height for tiles, dependent of tile position.
    # # Center tiles have overlapping on each side.
    # # Borders have no overlapping on the border side and overlapping on all other sides.
    # # Corners have only overlapping on the right and lower border.
    # def tile_dimensions(x, y, tile_size, overlap)
    #   overlapping_tile_size = tile_size + (2 * overlap)
    #   border_tile_size      = tile_size + overlap
    #
    #   tile_width  = (x > 0) ? overlapping_tile_size : border_tile_size
    #   tile_height = (y > 0) ? overlapping_tile_size : border_tile_size
    #
    #   [tile_width, tile_height]
    # end
    #
    # # Calculates how often an image with given dimension can
    # # be divided by two until 1x1 px are reached.
    # def max_level(width, height)
    #   (Math.log([width, height].max) / Math.log(2)).ceil
    # end
    #
    # # Crops part of src image and writes it to dest path.
    # #
    # # Params: src: may be an Magick::Image object or a path to an image.
    # #         dest: path where cropped image should be stored.
    # #         x, y: offset from upper left corner of source image.
    # #         width, height: width and height of cropped image.
    # #         quality: compression level 0-100 (or 0.0-1.0), lower number means higher compression.
    # def save_cropped_image(image, dest_path, x, y, tile_width, tile_height, quality = 75)
    #   tmp_file_path = "#{Pathname(image.path).dirname}/#{SecureRandom.hex}.#{@tile_format}"
    #   `convert -crop #{tile_width}x#{tile_height}+#{x}+#{y} #{image.path} #{tmp_file_path}`
    #   @storage.write(MiniMagick::Image.open(tmp_file_path), dest_path, quality: quality)
    #   `rm #{tmp_file_path}`
    # end
  end
end
