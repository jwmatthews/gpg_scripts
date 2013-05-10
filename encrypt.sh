source ./source_me

gpg --import --no-default-keyring --keyring ${KEY_RING} ${MY_PUB_KEY}
gpg --no-default-keyring --keyring ${KEY_RING} --trust-model always --output ${FILE_TO_DECRYPT} -ear ${MY_NAME} ${FILE_TO_ENCRYPT}
