#!/bin/bash -e

USERNAME=${USERNAME-root}

RESET=0
while [ $# -gt 0 ]; do
    case $1 in
        --reset)
            RESET=1
        ;;
    esac
done

SSH_DIR=$(eval echo ~${USERNAME})/.ssh
[ -d ${SSH_DIR} ] || mkdir -p ${SSH_DIR}
[ ${RESET} == 0 ] || > ${SSH_DIR}/authorized_keys
cat >> ${SSH_DIR}/authorized_keys
chmod 700 ${SSH_DIR}/authorized_keys
chown ${USERNAME} ${SSH_DIR}/*
