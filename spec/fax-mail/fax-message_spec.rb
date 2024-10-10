RSpec.describe 'FAX・スキャナのTIFF/JPG/PNGメールを整形' do
  it " tidy up Mail ( jpeg )" do
    load_sample_mail = lambda{|name|
      mail_str = File.read(File.realpath File.join(File.dirname(__FILE__), "./../mail-parse/sample/#{name}"))
      Mail.read_from_string mail_str
    }

    m1 = load_sample_mail.call('scanned_jpg.eml')
    im = FaxMessage.new(m1)
    m2 = im.tidy_attachments


    ##
    original = m1.attachments[0].body.decoded
    revised = m2.attachments[0].body.decoded

    expect(original.size).not_to eq revised.size
    expect((original.size-revised.size).abs/1024 < original.size*0.1 ).to be true
    expect(m1.subject).to eq m2.subject
    expect(m1.from).to eq m2.from
    expect(m1.to).to eq m2.to
    expect(m1.attachments.size).to eq m2.attachments.size

  end
  it " tidy up Mail (tiff single)" do

    load_sample_mail = lambda{|name|
      mail_str = File.read(File.realpath File.join(File.dirname(__FILE__), "./../mail-parse/sample/#{name}"))
      Mail.read_from_string mail_str
    }
    m1 = load_sample_mail.call('tiff-singlepage.eml')
    im = FaxMessage.new(m1)
    m2 = im.tidy_attachments

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
  it " tidy up Mail (tiff multi page)" do

    load_sample_mail = lambda{|name|
      mail_str = File.read(File.realpath File.join(File.dirname(__FILE__), "./../mail-parse/sample/#{name}"))
      Mail.read_from_string mail_str
    }
    m1 = load_sample_mail.call('tiff-multipage.eml')
    im = FaxMessage.new(m1)
    m2 = im.tidy_attachments

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