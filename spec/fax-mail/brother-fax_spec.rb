RSpec.describe 'Brother-MFC-J67 の射出メールをテスト' do
  it "メールからデータを取り出してTiff（シングル）を変換する。" do
    mail_str = File.read(File.realpath File.join(File.dirname(__FILE__), './../mail-parse/sample/tiff-singlepage.eml'))
    orig_mail = Mail.read_from_string mail_str
    b = BrotherFaxMessage.new mail_str
    png_mail = b.modify_mail

    ## 添付ファイル以外は全部おなじになるはず。
    expect(png_mail.to).to eq orig_mail.to
    expect(png_mail.from).to eq orig_mail.from
    expect(png_mail.subject).to eq orig_mail.subject
    expect(png_mail.message_id).to eq orig_mail.message_id
    expect(png_mail.boundary).to eq orig_mail.boundary
    expect(png_mail.date).to eq orig_mail.date
    expect(png_mail.content_type).to eq orig_mail.content_type
    expect(ImgTiffMessage.select_attachment(png_mail,'tiff')).to be_empty

  end
  it "メールからデータを取り出してTiff（マルチページ）を変換する。" do
    mail_str = File.read(File.realpath File.join(File.dirname(__FILE__), './../mail-parse/sample/tiff-multipage.eml'))
    orig_mail = Mail.read_from_string mail_str
    b = BrotherFaxMessage.new mail_str
    png_mail = b.modify_mail

    ## 添付ファイル以外は全部おなじになるはず。
    expect(png_mail.to).to eq orig_mail.to
    expect(png_mail.from).to eq orig_mail.from
    expect(png_mail.subject).to eq orig_mail.subject
    expect(png_mail.message_id).to eq orig_mail.message_id
    expect(png_mail.boundary).to eq orig_mail.boundary
    expect(png_mail.date).to eq orig_mail.date
    expect(png_mail.content_type).to eq orig_mail.content_type
    expect(ImgTiffMessage.select_attachment(png_mail,'tiff')).to be_empty
    ## 添付ファイルは枚数が増えてるはず。
    expect(png_mail.attachments.size).to be > orig_mail.attachments.size

  end

end
