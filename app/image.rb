module X
  class Image
    include Magick
    attr_accessor :image, :space, :raw_pixels, :pixels,
                  :encrypted_pixels, :result_pixels, :decrypted_pixels,
                  :processed_pixels

    def initialize(filename,space='rgb')
      @image = Magick::Image.read("images/#{filename}").first
      @space = space
      @raw_pixels = image.export_pixels(0, 0, @image.columns, @image.rows, "RGB")
      if @space == 'gray'
        @pixels = get_gray_pixels
      elsif @space == 'rgb'
        @pixels = get_rgb_pixels
      end
    end

    def get_gray_pixels
      @pixels = raw_pixels.each_slice(3).to_a.map{|a| a.uniq}.flatten
    end

    def get_rgb_pixels
      @pixels = raw_pixels
    end

    def columns
      image.columns
    end

    def rows
      image.rows
    end

    def encrypt_pixels(x)
      @encrypted_pixels = pixels.map{|p| x.encrypt(p)}
    end

    def merge_images(image2)
      @result_pixels = []

      encrypted_pixels.each_with_index do |pixel,i|
        @result_pixels << pixel.add(image2.encrypted_pixels[i]).scalar_div(2)
      end
    end

    def increase_brightness(x,constant)
      @result_pixels = []

      encrypted_pixels.each_with_index do |pixel,i|
        @result_pixels << pixel.add(constant)
      end
    end

    def decrease_brightness(x,constant)
      @result_pixels = []

      encrypted_pixels.each_with_index do |pixel,i|
        @result_pixels << pixel.sub(constant)
      end
    end

    def stamp_image(x,image2,factor)
      @result_pixels = []

      encrypted_pixels.each_with_index do |pixel,i|
        @result_pixels << pixel.add(image2.encrypted_pixels[i].scalar_mul(factor))
      end
    end

    def contrast_stretching(x,ca,cc,s_h)
      @result_pixels = []

      encrypted_pixels.each_with_index do |pixel,i|
        @result_pixels << pixel.sub(cc).scalar_mul(s_h).add(ca)
      end
    end

    def logical_not(x,cmax)
      @result_pixels = []

      encrypted_pixels.each_with_index do |pixel,i|
        @result_pixels << cmax.sub(pixel)
      end
    end

    def subtraction(x,image2)
      @result_pixels = []

      encrypted_pixels.each_with_index do |pixel,i|
        @result_pixels << pixel.sub(image2.encrypted_pixels[i])
      end
    end

    def decrypt_pixels(x)
      if space == 'gray'
        @decrypted_pixels = result_pixels.map{|a| [a] * 3}.flatten.map{|p| x.decrypt(p)}
      elsif space == 'rgb'
        @decrypted_pixels = result_pixels.map{|p| x.decrypt(p)}
      end
    end

    def process_pixels
      @processed_pixels = decrypted_pixels.map do |d|
        if d < 0
          0
        elsif d > 65535
          65535
        else
          d
        end
      end
    end

    def save_result_image
      process_pixels
      result = image.import_pixels(0, 0, image.columns, image.rows, "RGB", processed_pixels)
      result.write "images/result.jpg"
      result
    end

  end
end
