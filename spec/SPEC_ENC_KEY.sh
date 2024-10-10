
openssl enc -e -aes-256-cbc -pbkdf2 -iter 10000000 -base64 -in SPEC_ENC_KEY.txt -out SPEC_ENC_KEY.txt.encrypted
openssl enc -d -aes-256-cbc -pbkdf2 -iter 10000000 -base64 -in SPEC_ENC_KEY.txt.encrypted
