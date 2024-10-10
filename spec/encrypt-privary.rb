## spec フォルダ内部の .enc ファイルを復号化する。

require 'openssl/utils'

$pass = ENV['SPEC_ENC_KEY']

## abc.txt.encryption -> abc.txt
def decrypt_file(enc, password, ext = '.encrypted', iter = 1000 * 1000)
  f_in = enc
  f_out = f_in.sub(ext, '')
  OpenSSLEncryption.decrypt_by_ruby(
    passphrase: password,
    file_enc: f_in,
    file_out: f_out,
    iterations: iter,
    base64: true
  )
end

def encrypt_file(src, password, ext = ".encrypted", iter = 1000 * 1000)
  f_in = src
  f_out = "#{src}#{ext}"
  OpenSSLEncryption.encrypt_by_ruby(
    passphrase: password, file_in: f_in, file_out: f_out, iterations: iter, base64: true, salted: true)
  File.unlink f_in
end

def decrypt_files_in_repository(ext = '.encrypted')
  repo_home = File.realpath(File.dirname(File.dirname(__FILE__) + '/../..'))
  Dir.chdir repo_home
  files = Dir.glob("./**/*#{ext}", File::FNM_PATHNAME)
  files.each do |f|
    decrypt_file(f, $pass)
  end

end

def encrypt_files_in_repository(*patterns)
  repo_home = File.realpath(File.dirname(File.dirname(__FILE__) + '/../..'))
  Dir.chdir repo_home
  files = patterns.map { |pat| Dir.glob(pat) }.flatten.sort
  files.each do |f|
    encrypt_file(f, $pass)
  end
end

## main
if __FILE__==$0
  encrypt_files_in_repository('spec/**/*.jpg', 'spec/**/*.eml','spec/**/*.json', 'credentials/*.yaml', 'credentials/*.json')
end
