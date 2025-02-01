# aanno's aio-on-focos

This is a compose file for podman especially for FCOS.

Copy `env.template` and adapt it to your needs.

Status:

* Work-around for configs property (currently _not_ supported by podman)
* Currently not running on 'local' domain
  + setup works but https://nextcloud.local/ returns blank page
* unsure about port 8443

## Tipps and tricks

* [retrieve AIO passphrase after setup](https://github.com/nextcloud/all-in-one/discussions/1786)
* [WARNING: The X variable is not set. Defaulting to a blank string.](https://github.com/docker/compose/issues/4189)
* [docker compose: .env files and env_file property](https://docs.docker.com/compose/how-tos/environment-variables/set-environment-variables/)

* [Connection refused / 502 / Upgrade-Insecure-Requests](https://caddy.community/t/connection-refused-502-upgrade-insecure-requests-error-for-a-single-app-the-rest-work-fine/18742)

## AIO gotchas

```bash
sudo systemctl status firewalld.service 
sudo systemctl stop firewalld.service 
sudo systemctl disable firewalld.service 
```

* fcos enables *firewall*
  + simplest solution is to disable firewall
  + firewall might be up again after fcos upgrades
* proxy has to run in *host_mode*
  + using non-host more will interfere with the aio magic
* standalone (i.e. _without_ proxy) will not work (as well)
  + reason seems to be that domaincheck container does not work properly on fcos


```bash
CONTAINER ID  IMAGE                                       COMMAND     CREATED             STATUS                     PORTS                                                                         NAMES
167e868f5255  docker.io/nextcloud/all-in-one:latest                   About a minute ago  Up About a minute          0.0.0.0:80->80/tcp, 0.0.0.0:8080->8080/tcp, 0.0.0.0:8443->8443/tcp, 9000/tcp  nextcloud-aio-mastercontainer
f1db6aa8580c  docker.io/nextcloud/aio-domaincheck:latest              36 seconds ago      Exited (0) 36 seconds ago  0.0.0.0:443->443/tcp                                                          nextcloud-aio-domaincheck
```

## temporary add interface, static ip addr, and route

```bash
ip addr add 192.168.27.1/24 dev enp9s0
ip route add 192.168.27.0/24 dev enp9s0
```

```bash
```

```bash
```

## AIO podman compatibility

* [I would like to enhance the AIO compatibility with podman](https://github.com/nextcloud/all-in-one/discussions/5994)
* [how to run aio image using podman](https://github.com/nextcloud/all-in-one/discussions/5090#discussioncomment-11957699)
* [docker engine socket api](https://docs.docker.com/reference/api/engine/version/v1.39/)
* [Make podman more compatible with docker so I can run nextcloud all-in-one (AIO) on it](https://github.com/containers/podman/discussions/25125)
* [Make it more easy to modify /etc/hosts from within container by having it read-write (rw)](https://github.com/containers/podman/issues/25126)


## mastercontainer

### php code

```bash
$ sudo dnf install composer php-sodium php-pecl-apcu-devel
$ cd php
$ composer install
```
