require_relative 'magick/utils'
require_relative './FaxMessage'
class BrotherFaxMessage

  def initialize(mail_encoded)
    @mail_encoded = mail_encoded
    @png_mail = nil
  end

  # @return [Mail::Message]
  def modify_mail
    @fax_message = FaxMessage.new Mail.read_from_string @mail_encoded
    @fax_message.tidy_attachments
  end

end