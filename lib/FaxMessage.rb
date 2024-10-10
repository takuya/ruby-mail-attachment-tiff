
require_relative './ImgMessage'
require_relative './ImgTiffMessage'
class FaxMessage
  # @param mail [Mail::Message]
  def initialize(mail)
    @original_mail = mail
    @modified_mail = nil
  end
  def tidy_attachments
    @tiff_revised = ImgTiffMessage.new(@original_mail).convert_to_png
    @deskewed = ImgMessage.new(@tiff_revised).convert_to_deskew
    @modified_mail = @deskewed
  end
end
