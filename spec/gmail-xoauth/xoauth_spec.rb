RSpec.describe 'XOAuthの接続テスト（他テストでつかう）' do
  it "imap can be connected" do
    imap  = connect_imap_by_xoauth2
    ret = imap.noop
    expect(ret.data.text).to eq 'Success'
    expect(ret.name).to eq 'OK'
  end

  it "smtp can be connected" do
    smtp  = connect_smtp_by_xoauth2
    res = smtp.helo :helo
    expect(res.status).to eq "250"
  end
end
