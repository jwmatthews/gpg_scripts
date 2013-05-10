source ./source_me

gpg --import --no-default-keyring --keyring ${KEY_RING} ${THEIR_PUB_KEY}
gpg --export --no-default-keyring --keyring ${KEY_RING} -a ${THEIR_NAME} > ${OUT_DIR}/${THEIR_NAME}.pub.key
