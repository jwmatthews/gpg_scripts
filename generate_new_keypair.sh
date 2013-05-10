source ./source_me

function generate_key {
    KEY=$1
    GPG_PUBLIC=$2
    GPG_SECRET=$3
    NAME="${KEY}"
    COMMENTS="${KEY} generated at `date`"
    EMAIL="splice-reports@redhat.com"

    gpg2 --batch --gen-key <<EOF
        %echo Generating a basic OpenPGP key
        %echo If script pauses move mouse to generate more entropy
        Key-Type: DSA
        Key-Length: 1024
        Subkey-Type: ELG-E
        Subkey-Length: 1024
        Name-Real: ${NAME}
        Name-Comment: ${COMMENTS}
        Name-Email: ${EMAIL}
        Expire-Date: 0
        %pubring ${GPG_PUBLIC}
        %secring ${GPG_SECRET}
        # Do a commit here, so that we can later print "done" :-)
        %commit
        %echo done
        %echo Public key written to: ${GPG_PUBLIC}
        %echo Secert key written to: ${GPG_SECRET}
EOF
}

generate_key ${MY_NAME} ${MY_PUB_KEY} ${MY_SEC_KEY}
