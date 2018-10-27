#!/bin/bash

reformat () {
    mkfs.${MOUNT_FS} ${MAPPED_DEVICE_PATH}
}

setup_loopback () {
    # at first deactivate all previously assigned loopback devices
    for prev_loopback in $(losetup -a |grep "${ENC_FILE}" | cut -d":" -f1); do
        losetup -d ${prev_loopback}
    done

    loopback_device=$(losetup -f)
    losetup ${loopback_device} ${ENC_FILE} > /dev/null
    echo ${loopback_device}
}

exec_hooks () {
    echo " >> Executing hooks ${1}"

    if [[ -d ${HOOKS_DIR}/${1}/ ]]; then
        echo " .. ${f}"
        for f in ${HOOKS_DIR}/${1}/*.sh; do
            bash ${f}

            if [[ $? > 0 ]]; then
                echo " .. ${f} exited with non-zero status code"
                exit 1
            fi
        done
    fi
}

mount_mapped_volume () {
    exec_hooks "pre_mount"
    mkdir -p ${MOUNT_PATH}
    mount ${MAPPED_DEVICE_PATH} ${MOUNT_PATH}/ || exit 1
    exec_hooks "post_mount"
}

umount_previously_mounted_volume () {
    exec_hooks "pre_unmount"

    if [[ -d ${MOUNT_PATH} ]]; then
        umount ${MOUNT_PATH} 2> /dev/null
    fi

    if [[ -e ${MAPPED_DEVICE_PATH} ]]; then
        echo " .. Closing the previously opened device"
        cryptsetup close ${MAPPED_DEVICE_PATH}
    fi

    exec_hooks "pre_unmount"
}

decrypt () {
    passphrase=$1
    loopback_device=$(setup_loopback)

    tc-mount-volume.sh "${MOUNT_NAME} -d ${loopback_device}" ${passphrase}
    sleep 1

    if [[ ! -e ${MAPPED_DEVICE_PATH} ]]; then
        echo " .. Cannot decrypt volume"
        exit 1
    fi
}

verify_and_exit () {
    if mount | grep ${MOUNT_PATH} > /dev/null; then
        exit 0
    fi

    echo " .. Cannot find ${MOUNT_PATH} in the list of active mount points"
    exit 1
}
