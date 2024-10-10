require "mini_magick"

module MagickUtils
  class << self
    def tiff_to_png(tiff_img_bin)
      raise ArgumentError unless is_tiff(tiff_img_bin)
      ## tiff を png に変換する
      result = MiniMagick.convert.stdin.merge!(['PNG:-']).call(stdin: tiff_img_bin).force_encoding('ASCII-8BIT')
      delimiter = "\x89PNG\r\n".force_encoding('ASCII-8BIT')
      result.split(/(?=#{Regexp.escape(delimiter)})/)
    end

    def is_png(data)
      MiniMagick.identify.stdin.call(stdin: data)=~/PNG/ ? true : false
    end

    def is_tiff(data)
      MiniMagick.identify.stdin.call(stdin: data)=~/TIFF/ ? true : false
    end
    def is_multi_page_tiff(data)
      result = MiniMagick.identify.stdin.call(stdin: data)
      result =~/TIFF/ && result.lines.size>1 ? true : false
    end

    def is_jpg(data)
      MiniMagick.identify.stdin.call(stdin: data)=~/JPEG/ ? true : false
    end

    def deskew_image(image_binary, type = nil)
      MiniMagick
        .convert
        .stdin
        .deskew('40%')
        .merge!([type ? "#{type}:-" : '-'])
        .call(stdin: image_binary)
        .force_encoding('ASCII-8BIT')
    end

  end
end