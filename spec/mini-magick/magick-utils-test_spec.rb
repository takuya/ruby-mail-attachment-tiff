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
  it "can deskew image into same type (TIFF)" do
    tiff_bin = MiniMagick.convert.stdin.merge!(['TIFF:-']).call(stdin: img_bin).force_encoding('ASCII-8BIT')
    deskew_bin = MagickUtils.deskew_image(tiff_bin,nil)
    expect(MagickUtils.is_tiff(deskew_bin)).to be true
    expect(Digest::MD5.hexdigest(deskew_bin)).not_to eq Digest::MD5.hexdigest(tiff_bin)
  end

end