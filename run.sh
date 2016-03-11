#!/bin/bash -e

USERNAME=${USERNAME-root}
PASSWORD=${PASSWORD-password}
DATADIR=${DATADIR-/tmp}
AUTHORIZED_NETS="*"
DAEMON=${DAEMON-ssh}
DATA_DIRNAME=${DATA_DIRNAME-data}

if ! [ -z ${USERID} ]; then
    USERADD_OPTIONS="--uid ${USERID}"
fi

id -u ${USERNAME} >/dev/null 2>/dev/null || useradd ${USERADD_OPTIONS} --create-home ${USERNAME}
echo AllowUsers ${USERNAME} >> /etc/ssh/sshd_config

case ${DAEMON} in
    rsync)
        if [ "x${AUTHORIZED_NETS}" == "x" ]; then
            for ip in $(ip addr | grep '\<inet\>' | awk '{print $2}'); do
                AUTHORIZED_NETS="${ip} ${AUTHORIZED_NETS}"
            done
        fi

        if ! [ -f /etc/rsyncd.secrets ]; then
        cat > /etc/rsyncd.secrets <<EOF
${USERNAME}:${PASSWORD}
EOF
            chmod 400 /etc/rsyncd.secrets
        fi

        if [ -e /var/run/rsyncd.pid ]; then
            rm /var/run/rsyncd.pid
        fi
        [ -f /etc/rsyncd.conf ] || cat <<EOF > /etc/rsyncd.conf
pid file = /var/run/rsyncd.pid
log file = /dev/stdout
timeout = 300
max connections = 10
[${DATA_DIRNAME}]
    uid = ${USERNAME}
    gid = ${USERNAME}
    hosts deny = *
    hosts allow = ${AUTHORIZED_NETS}
    read only = false
    path = ${DATADIR}
    comment = data repository
    auth users = ${USERNAME}
    secrets file = /etc/rsyncd.secrets
EOF

        exec /usr/bin/rsync --no-detach --daemon
    ;;
    ssh)
        [ -d /var/run/sshd ] || mkdir -p /var/run/sshd
        exec /usr/sbin/sshd -D -e
    ;;
    *)
        exec tail -f /dev/null
    ;;
esac
