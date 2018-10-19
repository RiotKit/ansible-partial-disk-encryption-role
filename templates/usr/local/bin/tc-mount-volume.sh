#!/bin/bash

TCPLAY_PARAMS=$1
PASSPHRASE=$2

expect -c "
    spawn tcplay -m ${TCPLAY_PARAMS};
    set timeout 2;

    expect 'Passphrase: ';
    send ${PASSPHRASE}\r;

    expect 'Passphrase: ';
    send ${PASSPHRASE}\r;

    interact;
" > /tmp/test

sleep 1
exit $?
