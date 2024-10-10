
class ImgMessage
  def initialize(mail)
    @original_mail = mail
    @modified_mail = nil
  end
  def convert_to_deskew(from=nil)
    m1 = from || @original_mail
    m2 = Mail.new do
      ## copy basics
      from m1.from
      to m1.to
      subject m1.subject
      text_part do
        content_type m1.text_part.content_type
        body m1.text_part.body.to_s
      end
    end
    ## modify attachment
    m2 = copy_attachment(from: m1, to: m2)
    m2 = deskew_attachment(m2)
    ## copy others
    m2.message_id = m1.message_id
    m2.date = m1.date
    m2.header['Content-Type'] = "multipart/mixed; boundary=#{m1.boundary}"
    m2.body.boundary = m1.body.boundary
    @modified_mail = m2
  end
  protected
  # @param mail [Mail::Message]
  def deskew_attachment(mail)
    mail.attachments.each do |a|
      if  (a.mime_type && a.mime_type =~ /image/) || (a.filename && a.filename =~ /png|tiff?|jpe?g|/ )
        ## TIFF: negative image positions unsupported
        # Tiff のマルチページはエラーになる。
        a.body= MagickUtils.deskew_image(a.body.decoded)
     end
    end
    mail
  end
  def copy_attachment(from:, to:)
    m1, m2 = from, to
    # @type a [Mail::Part]
    m1.attachments.each do |a|
      if a.mime_type && a.filename
        m2.attachments[a.filename] = { mime_type: a.mime_type, content: a.body.decoded }
      else
        m2.attachments << a
      end
    end
    m2
  end
end