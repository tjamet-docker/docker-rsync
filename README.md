# docker-rsync
rsync container for remote development

## Features

* Synchronize directories and files using rsync protocol

Starting container
```
docker run --volume <DirectoryToSync> -e DATADIR=<DirectoryToSync> -e DAEMON=rsync tjamet/rsync
```

On your local host run
```
rsync -avz directory rsync://<containerIp>/data
```

* Synchronize directories and files using rsync over ssh remote shell

Starting container
```
docker run --name rsync-container --volume <DirectoryToSync> -e DAEMON=rsync tjamet/rsync
cat <YourPublicKey> | docker exec -i rsync-container add-ssh-key
```

On your local host, run
```
rsync -avz -e 'ssh' . root@<containerIp>:<DirectoryToSync>
```

* Synchronize directories and files using rsync over docker remote shell

Starting container
```
docker run --name rsync-container --volume <DirectoryToSync> -e DAEMON=docker tjamet/rsync
```

On your local host, run
```
rsync -avz -e 'docker exec -i' . rsync-container:<DirectoryToSync>
```

## Customize run

Customization should be done by setting environment variables at `docker run` time

### rsync daemon
* Change directory by setting DATADIR
* Change destination name by setting DATA_DIRNAME
* Change daemon user name by setting USERNAME
* Change password by setting PASSWORD
* Restrict allowed IPs by setting AUTHORIZED_NETS (x.x.x.x/mask)

### ssh daemon
* Change daemon user name by setting USERNAME
* Reset ssh-key by running
```
cat <YourPublicKey> | docker exec -i rsync-container add-ssh-key --reset
```
* Add another ssh-key by running
```
cat <YourPublicKey> | docker exec -i rsync-container add-ssh-key
```

Note: using the docker remote shell is not fully supported with docker clients < 1.10
