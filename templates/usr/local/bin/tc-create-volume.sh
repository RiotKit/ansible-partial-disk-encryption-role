#!/bin/bash

set -x

TCPLAY_PARAMS=$1
PASSPHRASE=$2
HIDDEN_VOLUME_PASSPHRASE=$3
HIDDEN_VOLUME_SIZE=$4

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
"
