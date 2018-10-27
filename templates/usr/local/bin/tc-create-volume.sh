#!/bin/bash

set -x

TCPLAY_PARAMS=$1
MOUNT_NAME=$2
PASSPHRASE=$3
HIDDEN_VOLUME_PASSPHRASE=$4
HIDDEN_VOLUME_SIZE=$5

expect -c "
    spawn tcplay -c ${TCPLAY_PARAMS};
    set timeout 1;

    expect 'Passphrase: ';
    send ${PASSPHRASE}\r;

    expect 'Repeat passphrase: ';
    send ${PASSPHRASE}\r;

    expect 'volume: ';
    send ${HIDDEN_VOLUME_PASSPHRASE}\r;

    expect 'Repeat passphrase:';
    send ${HIDDEN_VOLUME_PASSPHRASE}\r;

    expect 'volume';
    send ${HIDDEN_VOLUME_SIZE}\r;

    expect 'you';
    send y\r;

    interact;
" > /tmp/create.log

cat /tmp/create.log

if [[ $(cat /tmp/create.log) != *"Writing volume headers to disk..."* ]]; then
    echo " .. Failed to create a volume"
    exit 1
fi

/usr/local/bin/tcmount-${MOUNT_NAME}.sh ${PASSPHRASE} --format
exit $?
