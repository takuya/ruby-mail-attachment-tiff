require 'mail'

RSpec.describe 'TIFFメールをpngにしてDeskewする' do
  it "TIFF(シングル）をDeskew する" do
    path = File.join(File.dirname(__FILE__), 'sample/tiff-singlepage.eml')
    m1 = Mail.read path
    m1.has_attachments?
    tiff_part= m1.attachments.find{|e| e.content_type =~ /tif/}
    img_bin = tiff_part.body.decoded
    result = MiniMagick.convert.stdin.merge!(['PNG:-']).call(stdin:img_bin).force_encoding('ASCII-8BIT')
    delimiter = "\x89PNG\r\n".force_encoding('ASCII-8BIT')
    pages = result.split(/(?=#{Regexp.escape(delimiter)})/)
    deskew_pages = pages.map { |page|
      page = MiniMagick.convert.stdin.deskew('40%').merge!(['PNG:-']).call(stdin:page)
      page = page.force_encoding('ASCII-8BIT')
      page
    }
    deskew_pages.each{|page|
      expect(MiniMagick.identify.stdin.call(stdin:page)).to match /PNG/
    }
  end
  it "TIFF(マルチ）をDeskew する" do
    path = File.join(File.dirname(__FILE__), 'sample/tiff-multipage.eml')
    m1 = Mail.read path
    m1.has_attachments?
    tiff_part= m1.attachments.find{|e| e.content_type =~ /tif/}
    img_bin = tiff_part.body.decoded
    result = MiniMagick.convert.stdin.merge!(['PNG:-']).call(stdin:img_bin).force_encoding('ASCII-8BIT')
    delimiter = "\x89PNG\r\n".force_encoding('ASCII-8BIT')
    pages = result.split(/(?=#{Regexp.escape(delimiter)})/)
    deskew_pages = pages.map { |page|
      page = MiniMagick.convert.stdin.deskew('40%').merge!(['PNG:-']).call(stdin:page)
      page = page.force_encoding('ASCII-8BIT')
      page
    }
    deskew_pages.each{|page|
      expect(MiniMagick.identify.stdin.call(stdin:page)).to match /PNG/
    }
  end

end