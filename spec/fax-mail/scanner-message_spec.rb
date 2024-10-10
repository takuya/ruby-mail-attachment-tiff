RSpec.describe 'fax/scanner tiff message' do
  it " can deskew_image (JPG)" do
    m1 =  Mail.new do
      from 'dummy'
      to 'dummy'
      subject "sample"
      text_part do
        content_type 'text/plain'
        body 'this is sample mail.'
      end
    end

    m1.attachments['photo.png'] = File.read(File.join(File.dirname(__FILE__), "../photo.jpg"))


    im = ImgMessage.new(m1)
    m2 = im.convert_to_deskew

    original = m1.attachments[0].body.decoded
    deskewed = m2.attachments[0].body.decoded

    expect(original.size).not_to eq deskewed.size
    expect((original.size-deskewed.size).abs/1024).to eq 0
    expect(m1.subject).to eq m2.subject
    expect(m1.from).to eq m2.from
    expect(m1.to).to eq m2.to
    expect(m1.attachments.size).to eq m2.attachments.size


  end
  it " cannot deskew_image (TIFF)" do
    load_sample_mail = lambda{|name|
      mail_str = File.read(File.realpath File.join(File.dirname(__FILE__), "./../mail-parse/sample/#{name}"))
      Mail.read_from_string mail_str
    }
    ##
    expect{
      im = ImgMessage.new(load_sample_mail.call('tiff-singlepage.eml'))
      im.convert_to_deskew
    }.to raise_error MiniMagick::Error,/TIFF: negative image positions unsupported/
    expect{
      im = ImgMessage.new(load_sample_mail.call('tiff-multipage.eml'))
      im.convert_to_deskew
    }.to raise_error MiniMagick::Error,/TIFF: negative image positions unsupported/


  end

end
