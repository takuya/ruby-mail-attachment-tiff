RSpec.describe 'Brother-MFC-J67 のメールをテスト' do
  it "変換したメールが正しく送信できるかテストする" do

    modify_mail = lambda{|uuid,user_id|
      load_sample_mail = lambda{|path|
        File.read(File.realpath File.join(File.dirname(__FILE__), path))
      }
      # 完全なコピーだと困るので、編集して送信
      mail = BrotherFaxMessage.new(load_sample_mail.call('./../mail-parse/sample/tiff-multipage.eml')).modify_mail
      mail.to = user_id # 自分宛てに送信
      mail.from = user_id
      mail.message_id = nil
      mail.subject = "#{mail.subject} -- #{uuid}"
      mail
    }
    send_mail_test = lambda{|uuid,user|
      ## メール本文を準備
      png_mail = modify_mail.call(uuid,user)
      ## メール送信
      smtp = connect_smtp_by_xoauth2
      res_sendmail = smtp.sendmail(png_mail.encoded, user, user)
      res_finish = smtp.finish
      ## メール送信チェック
      expect(res_sendmail.status).to eq '250'
      expect(res_sendmail.string).to match %r" OK "
      expect(res_finish.status).to eq '221'
      expect(res_finish.string).to match /gsmtp$/
      png_mail
    }
    receive_mail_check = lambda{|uuid,user|
      delete_mail = lambda{|imap,uid|
        imap.select('INBOX')
        imap.uid_store(uid, "+FLAGS", [:Seen])
        imap.uid_store(uid, "+FLAGS", [:Deleted])
        imap.expunge
      }
      imap = connect_imap_by_xoauth2
      imap.select('INBOX')
      search_criteria = ['SUBJECT', uuid]
      message_uid = imap.uid_search(search_criteria)[0]
      fetched_mail_str = imap.uid_fetch(message_uid, 'RFC822')[0].attr['RFC822']
      fetched_mail = Mail.read_from_string fetched_mail_str

      delete_mail.call(imap,message_uid)
      raise unless  imap.uid_search(search_criteria).empty?
      res_logout = imap.logout
      imap.disconnect
      raise unless res_logout.name == "OK"
      raise unless res_logout.data.text =~ /Success/
      raise unless imap.disconnected?


      expect(fetched_mail.subject).to match uuid

      fetched_mail

    }

    ## 編集したメールが送信できるかテスト
    uuid = SecureRandom.uuid
    vault = oauth_vault
    mail_send = send_mail_test.call(uuid,vault.user)
    ## 送信済みをテスト
    #
    ## IMAP にログインして受信メールを探し、比較。取り出したら削除。
    mail_received = receive_mail_check.call(uuid,vault.user)

    ## 送信したメールと受信メールを比較
    #
    expect(mail_received.subject).to eq mail_send.subject
    expect(mail_received.attachments.size).to eq mail_send.attachments.size


  end
end
