#!/bin/bash

KEYPATH=~/tf
mkdir -p $KEYPATH

genclient () {
    CLIENTKEYS="joe ian iggy-new fabian-2"
    for k in $CLIENTKEYS; do
        wg genkey | tee $KEYPATH/vp-devserver-$k-privatekey | wg pubkey > $KEYPATH/vp-devserver-$k-publickey
    done
}

genserver () {
    wg genkey | tee $KEYPATH/vp-vpngw-privatekey | wg pubkey > $KEYPATH/vp-vpngw-publickey
}


getghpubkeys () {
    USERLIST="josephramsay xycarto"
    for user in $USERLIST;
    do
        IFS=$','
        COUNTER=1
        PUBKEYS=$(curl https://api.github.com/users/$user/keys | jq '.[].key' | paste -sd, -)
        for key in $PUBKEYS;
        do
            echo $key > $KEYPATH/vp-gh-$user-$COUNTER-publickey
            COUNTER=$((COUNTER+1))
        done
        unset IFS
    done
    unset IFS

}

ssm (){
    echo aws ssm put-parameter \
        --name /wireguard/wg-server-private-key \
        --type SecureString \
        --value $(cat $KEYPATH/vp-vpngw-privatekey)
}

#genclient
#genserver
getghpubkeys
#ssm