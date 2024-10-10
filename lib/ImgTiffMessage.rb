class ImgTiffMessage

  def initialize(mail)
    @original_mail = mail
    @modified_mail = nil
  end

  def convert_to_png
    m1 = @original_mail
    m2 = Mail.new do
      from m1.from
      to m1.to
      subject m1.subject
      text_part do
        content_type m1.text_part.content_type
        body m1.text_part.body.to_s
      end
    end
    m2 = copy_attachment(from: m1, to: m2)
    m2.message_id = m1.message_id
    m2.date = m1.date
    m2.header['Content-Type'] = "multipart/mixed; boundary=#{m1.boundary}"
    m2.body.boundary = m1.body.boundary
    @modified_mail = m2
  end

  class << self
    def select_attachment(mail, type = 'png')
      (mail.attachments.select do |a|
        a.content_type && a.content_type=~/#{type}/ ||
          a.content_disposition && a.content_disposition=~/#{type};/
      end + []).flatten
    end
  end

  protected

  def tiff_attachments(message)
    self.class.select_attachment(message, 'tif?')
  end

  def convert_tiff_attachment_to_png(message)
    pages = []
    image_parts = tiff_attachments(message)
    tiff_images = image_parts.map { |part| img_bin = part.body.decoded }
    tiff_images.each do |tiff_bin|
      pages.push MagickUtils.tiff_to_png(tiff_bin)
    end
    pages.flatten
  end

  def copy_attachment(from:, to:)
    m1, m2 = from, to
    other_attachments = m1.attachments - tiff_attachments(m1)
    other_attachments.each do |a|
      m2.attachments[a.filename] = { mime_type: a.mime_type, content: a.body.decoded }
    end
    if tiff_attachments(m1)
      copy_tiff_attachment(from: m1, to: m2)
    end
  end

  def copy_tiff_attachment(from:, to:)
    m1, m2 = from, to
    png_pages = convert_tiff_attachment_to_png(m1)
    raise Error if png_pages.find { |page| !MagickUtils.is_png(page) }
    png_pages.each_with_index do |page, index|
      m2.attachments["image-#{index}.png"] = { mime_type: 'image/png', content: page }
    end
    m2
  end
end