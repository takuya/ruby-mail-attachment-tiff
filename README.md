## オフィス用複合機のTIFFファイルを処理する。

自宅にある複合機はSMTP機能がある。ただし、スキャンとFAXはTIFFで処理される。

ところが、TIFFに写真が複数枚含まれるマルチパート（ページ）のTIFFファイルで、一部のメールソフトのプレビューでは見れない。

特に問題なのが、複数枚が想定されてないため、最初の１枚しか見えない点である。

そこで、メール内容を変更して、マルチページTIFFを複数枚PNGにかえて送信する。

GmailでTIFF表示すると、複数枚のTIFFを見落としがちだったので、このファイルを作った。

SMTPをプロキシしてTiffファイルをpngに変換して送信する。

TIFF複数枚が表示できないことが発端。

いまのGmailは複数枚でも問題なく表示できるので、不要になった。


### install as gem
```shell
[ -e Gemfile ] || bundle init 
REPO_URL=https://github.com/takuya/ruby-mail-attachment-tiff.git
echo "gem 'takuya-ruby-mail-attachment-tiff', git: '$REPO_URL'" >> Gemfile
bundle install 
```

### testing
```shell
git clone https://github.com/takuya/ruby-mail-attachment-tiff.git
cd ruby-mail-attachment-tiff
bundle install 
bundle exec rspec spec
```

## ハマりどころ

image magick の convert で mutipage な tiff を 扱う場合 `+repage`をつける。 

つけないと`negative image positions unsupported` となり変換できているのにエラーになり、変換できているのにmini-magickが例外で落ちる。
