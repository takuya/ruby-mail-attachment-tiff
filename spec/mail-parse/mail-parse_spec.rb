require 'mail'

RSpec.describe 'メールの取得サンプル' do
  addr_fax = JSON.load_file("#{File.dirname(__FILE__)}/sample/address.json")['fax']
  addr_admin = JSON.load_file("#{File.dirname(__FILE__)}/sample/address.json")['admin']
  addr_user = JSON.load_file("#{File.dirname(__FILE__)}/sample/address.json")['user']

  it "Mail.read でメールを開く" do
    path= File.join(File.dirname( __FILE__), 'sample/simple.eml')
    m1  = Mail.read path
    expect(m1.text?).to be true
    expect(m1.multipart?).to be false
    expect(m1.from).to eq [addr_admin]
    expect(m1.to).to eq [addr_user]
    expect(m1.body.to_s).to eq 'hello'
    expect(m1.body.to_s).to eq m1.body.encoded
  end

  it "Mail#read_from_string src でメールを開く" do
    path= File.join(File.dirname( __FILE__), 'sample/simple.eml')
    src = File.read path
    m1 = Mail.read_from_string src
    expect(m1.text?).to be true
    expect(m1.multipart?).to be false
    expect(m1.from).to eq [addr_admin]
    expect(m1.to).to eq [addr_user]
    expect(m1.body.to_s).to eq 'hello'
    expect(m1.body.to_s).to eq m1.body.encoded
  end
  it "Mailを新しいオブジェクトに作り直す。" do
    path= File.join(File.dirname( __FILE__), 'sample/simple.eml')
    m1  = Mail.read path
    m2 = Mail.new do
      from    [addr_fax]
      to      m1.to
      subject m1.subject
      body    m1.body.decoded
    end
    expect(m2.text?).to be m1.multipart?
    expect(m2.multipart?).to be m1.multipart?
    expect(m2.from).to eq [addr_fax]
    expect(m2.to).to eq m1.to
    expect(m2.body.to_s).to eq m1.body.to_s
    expect(m2.message_id).to be nil
    ## message-ID は encode 後に作成される。
    m2.encoded
    expect(m2.message_id).not_to be nil
    expect(m2.message_id).not_to eq m1.message_id
  end


end

