RSpec.describe 'mini mini-magick のテスト' do
  img_bin = MiniMagick.convert
                      .resize('x240')
                      .stdin
                      .merge!(['JPG:-'])
                      .call(stdin: File.read(File.realpath File.join(File.dirname(__FILE__), '../photo.jpg')))
                      .force_encoding('ASCII-8BIT')

  it "test identify" do
    ##
    expect(MagickUtils.is_jpg(img_bin)).to be true
    expect(MagickUtils.is_png(img_bin)).to be false
    ##
    png_bin = MiniMagick.convert.stdin.merge!(['PNG:-']).call(stdin: img_bin).force_encoding('ASCII-8BIT')
    expect(MagickUtils.is_png(png_bin)).to be true
    expect(MagickUtils.is_png(img_bin)).to be false
    ##
    tiff_bin = MiniMagick.convert.stdin.merge!(['TIFF:-']).call(stdin: img_bin).force_encoding('ASCII-8BIT')
    expect(MagickUtils.is_tiff(tiff_bin)).to be true
    expect(MagickUtils.is_tiff(png_bin)).to be false
  end
  it "test tiff to png array" do
    ##
    tiff_bin = MiniMagick.convert.stdin.merge!(['TIFF:-']).call(stdin: img_bin).force_encoding('ASCII-8BIT')
    png_pages = MagickUtils.tiff_to_png(tiff_bin)
    expect(png_pages).to respond_to(:to_a)
    expect { MagickUtils.tiff_to_png(img_bin) }.to raise_error(ArgumentError)
  end
  it "can deskew image" do
    deskew_bin = MagickUtils.deskew_image(img_bin, "JPG")
    expect(MagickUtils.is_jpg(deskew_bin)).to be true
    expect(Digest::MD5.hexdigest(deskew_bin)).not_to eq Digest::MD5.hexdigest(img_bin)
  end
  it "can deskew image into same type (JPEG)" do
    deskew_bin = MagickUtils.deskew_image(img_bin,nil)
    expect(MagickUtils.is_jpg(deskew_bin)).to be true
    expect(Digest::MD5.hexdigest(deskew_bin)).not_to eq Digest::MD5.hexdigest(img_bin)
  end
  it "can deskew image into same type (JPEG), +repage " do
    # +repage を無関係なふぁいるにつけても影響がないことを確認。
    deskew_bin_repage = MagickUtils.deskew_image(img_bin,nil,'+repage')
    deskew_bin_no_repage = MagickUtils.deskew_image(img_bin,nil)
    expect(MagickUtils.is_jpg(deskew_bin_repage)).to be true
    expect(Digest::MD5.hexdigest(deskew_bin_repage)).not_to eq Digest::MD5.hexdigest(img_bin)
    expect(Digest::MD5.hexdigest(deskew_bin_repage)).to eq Digest::MD5.hexdigest(deskew_bin_no_repage)
  end
  it "can deskew image into same type (TIFF/single)" do
    tiff_bin = MiniMagick.convert.stdin.merge!(['TIFF:-']).call(stdin: img_bin).force_encoding('ASCII-8BIT')
    deskew_bin = MagickUtils.deskew_image(tiff_bin,nil)
    expect(MagickUtils.is_multi_page_tiff(tiff_bin)).to eq MagickUtils.is_multi_page_tiff(deskew_bin)
    expect(MagickUtils.is_tiff(deskew_bin)).to be true
    expect(Digest::MD5.hexdigest(deskew_bin)).not_to eq Digest::MD5.hexdigest(tiff_bin)
  end
  it "can deskew image into same type (TIFF/multiple), +repage" do
    load_sample_mail = lambda{|name|
      mail_str = File.read(File.realpath File.join(File.dirname(__FILE__), "./../mail-parse/sample/#{name}"))
      Mail.read_from_string mail_str
    }
    m1 = load_sample_mail.call('tiff-multipage.eml')
    tiff_bin =  m1.attachments[0].body.decoded
    expect(MagickUtils.is_multi_page_tiff(tiff_bin)).to be true
    ## tiff multipage は `+repage`をつける
    # https://www.imagemagick.org/discourse-server/viewtopic.php?t=26416
    deskew_bin = MagickUtils.deskew_image(tiff_bin,nil,'+repage')
    expect(MagickUtils.is_multi_page_tiff(deskew_bin)).to be true
    expect(Digest::MD5.hexdigest(deskew_bin)).not_to eq Digest::MD5.hexdigest(tiff_bin)
  end

end