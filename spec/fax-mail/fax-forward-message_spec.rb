RSpec.describe 'fax tiff message' do
  it " can convert tiff to png (single) " do
    load_sample_mail = lambda{|name|
      mail_str = File.read(File.realpath File.join(File.dirname(__FILE__), "./../mail-parse/sample/#{name}"))
      Mail.read_from_string mail_str
    }
    im = ImgTiffMessage.new(m1 = load_sample_mail.call('tiff-singlepage.eml'))
    m2 = im.convert_to_png

    expect(m2.subject).to eq m1.subject
    expect(m2.from).to eq m1.from
    expect(m2.to).to eq m1.to
    expect(m2.boundary).to eq m1.boundary
    expect(m2.attachments.size).to eq m1.attachments.size

    original  = m1.attachments[0].body.decoded
    converted = m2.attachments[0].body.decoded

    expect(MagickUtils.is_tiff(original)).to be true
    expect(MagickUtils.is_png(converted)).to be true

  end
  it " can convert tiff to png (multi) " do
    load_sample_mail = lambda{|name|
      mail_str = File.read(File.realpath File.join(File.dirname(__FILE__), "./../mail-parse/sample/#{name}"))
      Mail.read_from_string mail_str
    }
    im = ImgTiffMessage.new(m1 = load_sample_mail.call('tiff-multipage.eml'))
    m2 = im.convert_to_png

    expect(m2.subject).to eq m1.subject
    expect(m2.from).to eq m1.from
    expect(m2.to).to eq m1.to
    expect(m2.boundary).to eq m1.boundary
    expect(m2.attachments.size).not_to eq m1.attachments.size ## ページ増えてることを確認

    original  = m1.attachments[0].body.decoded
    converted = m2.attachments[0].body.decoded

    expect(MagickUtils.is_tiff(original)).to be true
    expect(MagickUtils.is_png(converted)).to be true

  end

end
