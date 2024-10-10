
require 'mail'
require 'tempfile'
require "tmpdir"

RSpec.describe 'メール変換のテスト' do
  it "TIFF（マルチページ）のメールをPNG複数枚のメールにする" do
    path= File.join(File.dirname( __FILE__), 'sample/tiff-multipage.eml')
    m1  = Mail.read path
    m1.has_attachments?
    tiff_part= m1.attachments.find{|e| e.content_type =~ /tif/}
    img_bin = tiff_part.body.decoded
    result = MiniMagick.convert.stdin.merge!(['PNG:-']).call(stdin:img_bin).force_encoding('ASCII-8BIT')
    delimiter = "\x89PNG\r\n".force_encoding('ASCII-8BIT')
    pages = result.split(/(?=#{Regexp.escape(delimiter)})/)

    addr_fax = JSON.load_file("#{File.dirname(__FILE__)}/sample/address.json")['fax']

    m2 = Mail.new do
      from    [addr_fax]
      to      m1.to
      subject m1.subject
      body    m1.body.decoded
    end
    pages.each_with_index do |page, index|
      if page.include?(delimiter)
        filename = "image-#{index}.png"
        m2.attachments[filename] = {
          mime_type: 'image/png',
          content: page
        }
      end
    end
    m2.encoded
    expect(m2.message_id).not_to be nil
    expect(m2.has_attachments?).to be true
    expect(m2.attachments.size).to eq 3
    m2.attachments.each { |part|
      expect(part.mime_type).to eq 'image/png'
      expect(part.filename).to match /^image-\d+\.png$/
      expect(MiniMagick.identify.stdin.call(stdin:part.body.decoded)).to match /PNG/
    }

  end


end

