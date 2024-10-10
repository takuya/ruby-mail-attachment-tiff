require_relative 'magick/utils'
class BrotherScanMessage

  # @param [String] image_bin The binary image data encoded as ASCII-8BIT
  def self.deskew_image(image_bin)
    MagickUtils.deskew_image(image_bin, "PNG")
  end

  # @param message [Mail::Message]
  def self.convert_tiff_attachment_to_png(message)
    pages = []
    image_parts = self.tiff_attachments(message)
    tiff_images = image_parts.map { |part| img_bin = part.body.decoded }
    tiff_images.each do |tiff_bin|
      pages.push MagickUtils.tiff_to_png(tiff_bin)
    end
    pages.flatten
  end

  # @param message [Mail::Message]
  def self.tiff_attachments(message)
    message.attachments.select { |e| e.content_type =~ /tif/ }
  end

  def initialize(mail_encoded)
    @tiff_mail = Mail.read_from_string mail_encoded
    @png_mail = nil
  end

  # @return [Mail::Message]
  def modify_mail
    m1 = @tiff_mail
    m2 = Mail.new do
      from m1.from
      to m1.to
      subject m1.subject
      text_part do
        content_type m1.text_part.content_type
        body m1.text_part.body.to_s
      end
    end
    m2 = copy_tiff_attachment(from: m1, to: m2)
    m2.message_id = m1.message_id
    m2.date = m1.date
    m2.header['Content-Type'] = "multipart/mixed; boundary=#{m1.boundary}"
    m2.body.boundary = m1.body.boundary
    @png_mail = m2
  end

  def copy_tiff_attachment(from:, to:)
    m1, m2 = from, to
    png_pages = self.class.convert_tiff_attachment_to_png(m1)
    png_pages = png_pages.map { |png_bin| self.class.deskew_image(png_bin) }
    raise Error if png_pages.find { |page| !MagickUtils.is_png(page) }
    png_pages.each_with_index do |page, index|
      m2.attachments["image-#{index}.png"] = { mime_type: 'image/png', content: page }
    end
    m2
  end

end