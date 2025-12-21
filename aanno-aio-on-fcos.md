# aanno's aio-on-fcos

The [aio-on-fcos](https://github.com/aanno/all-in-one/tree/aanno/aio-on-fcos-coredns-wildcard-3/aio-on-fcos) directory contains a compose file for podman crafted especially for [FCOS](https://docs.fedoraproject.org/en-US/fedora-coreos/). This _includes_ that [nextcloud aio (all-in-one)](https://github.com/nextcloud/all-in-one) is _working_ **with podman** and on `podman compose`. However, automatic update is broken. But there is a _manual_ work around for this. Hence, it you want to run nextcloud aio on podman you should consider trying my work.

Copy `env.template` and adapt it to your needs.

Status:

* Work-around for configs property (as configs properties are currently _not_ supported by podman)
* Currently running on 'local' domain of your choice
  + setup works
  + https://nextcloud.my.local/ (AIO_DOMAIN) works
  + local base domains works
  + other sub domains do _not_ working locally (as there is no wildcard cert)
* Currently running on your.domain (you need an official DNS entry and probably a server on the internet)
  + setup works
  + configured domains are working
  + base domains are working
  + other sub domains do working _if_ you are able to get a wildcard cert. This normally means that caddy can modify DNS records. As my hosting provider is netcup, I configured this with netcup (see `aio-on-fcos/caddy_build/Dockerfile` for details). But it should be easy to use every DNS service caddy supports!
* talk currently _not_ working
* collabora currently _not_ working
* I'm working on a quadlet/systemd solution right now. Stay tuned!

## Overview and quickstart

Changes w.r.t. official aio:

* use of a dedicated DNS server ([coredns](https://coredns.io/)) to circumvent the 'self reference problem'
* use of docker compatible sockets to allow the mastercontainer to control aio container setup. 
  This is the very same as if aio is run with docker (i.e. ['manual install'](https://github.com/nextcloud/all-in-one/tree/main/manual-install) is NOT used)
* for this to work you need:
  + enable/start the podman socket and
  + carefully adapt the permission of the socket before running aio

### podman compose quickstart

1. enable podman socket with
   ```sh
   cd all-in-one/aio-on-fcos
   ./scripts/switchto-podman-socket.sh
   ```
2. Adapt the group of the socket to your needs (see section 'right socket group' below)
   ```sh
   sudo ./scripts/podman-socket-fix-perms.sh
   ```
3. Copy the `env.template` file to `.env` and adapt it to your needs
   ```sh
   cp env.template .env
   # nano .env
   ```
4. Create the neccessary network and volumes
   ```sh
   podman network create --subnet 10.89.57.0/24 --gateway 10.89.57.1 --dns 10.89.57.4 --driver bridge nextcloud-aio
   podman network create --subnet 10.89.58.0/24 --gateway 10.89.58.1 --dns 10.89.58.4 --driver bridge --ipv6 --subnet fd49:dc34:d0fe:ef6b:beaf::/80 --gateway fd49:dc34:d0fe:ef6b:beaf::1 --dns fd49:dc34:d0fe:ef6b:beaf::4 nextcloud-frontend
   ```
6. Run aio with:
   ```sh
   ./scripts/aio-start.sh
   ```
7. Stop aio with:
   ```sh
   ./scripts/aio-stop.sh
   ```

### right socket group

The group of the socket must be the right one. 

Example: If you run aio as user 'nc' (1003):

```sh
ls -l /run/user/$UID/podman/podman.sock 
srw-rw----. 1 nc 720928 0 Dec 21 11:03 /run/user/1003/podman/podman.sock
```

But where does this magic '720928' comes from?

See `/etc/subuid` contains the line:

```text
nc:720896:65536
```

and `/etc/subgid` contains the line:


```text
nc:720896:65536
```

Hence, the gid _inside the container_ used for the group is `720928 - 720896 + 1 = 33`!!!

```text
podman exec -it nextcloud-aio-mastercontainer bash

# and now - inside the container:
ls -l /var/run/docker.sock 
srw-rw----    1 root     www-data         0 Dec 21 11:03 /var/run/docker.sock

# what is the name of gid 33?
getent group 33
www-data:x:33:www-data,apache
```

If your setup is different you have to adapt the MY_GID variable of `aio-on-fcos/scripts/podman-socket-fix-perms.sh`.

## quadlet and systemd quickstart

### right socket group with systemd

Enable user's podman.socket at boot:

```bash
# As user 'nc'
systemctl --user enable podman.socket
```

```
# Verify linger is enabled
sudo loginctl enable-linger nc
```

Install systemd units (replace <UID_OF_NC> with actual UID from id -u nc):

```bash
sudo cp usr/local/bin/podman-socket-fixperms.sh /usr/local/bin/podman-socket-fixperms.sh
sudo cp systemd/system/podman-socket-fixperms.service /etc/systemd/system/podman-socket-fixperms.service

sudo chmod +x /usr/local/bin/podman-socket-fixperms.sh
sudo touch /var/log/podman-socket-fixperms.log
sudo chmod 644 /var/log/podman-socket-fixperms.log

# Install units
sudo systemctl daemon-reload
sudo systemctl enable podman-socket-fixperms.path
sudo systemctl start podman-socket-fixperms.path
```

Test triggers manually:

```bash
# Monitor in one terminal
sudo journalctl -u podman-socket-fixperms.service -u podman-socket-fixperms.path -f

# In another terminal as user 'nc':
systemctl --user restart podman.socket

# Check results:
tail -f /var/log/podman-socket-fixperms.log
systemctl status podman-socket-fixperms.service
systemctl status podman-socket-fixperms.path
```

Verify permissions:

```bash
ls -l /run/user/$(id -u nc)/podman/podman.sock
ls -l /run/user/$(id -u nc)/docker.sock
stat -c '%a %G' /run/user/$(id -u nc)/podman/podman.sock
```

Test full cycle:

```bash
# As user 'nc'
systemctl --user stop podman.socket
sleep 2
systemctl --user start podman.socket

# Check if service re-triggered
tail /var/log/podman-socket-fixperms.log
```

## Drawbacks

* podman is _not_ official supported for nextcloud aio, see [here](https://github.com/nextcloud/all-in-one?tab=readme-ov-file#can-i-run-this-with-podman-instead-of-docker)

### Drawback references

Main problem is that watchtower (the solution used for updating the container (and images) while running) is _not_ working with podman but

* nextcloud/all-in-one is moving away from this version of watchtower to
[FR: What differences does this fork of watchtower have?](https://github.com/nicholas-fedor/watchtower/discussions/267#discussioncomment-13201594), hence it might not be a problem with version v11.2.0 and up, see watchtower: [change to a well-maintained repo and add podman compatibility](https://github.com/nextcloud/all-in-one/pull/6533) for details

* [enhance the AIO compatibility with podman](https://github.com/nextcloud/all-in-one/discussions/5994)
* [Niklas Fedor's modern fork of ](https://watchtower.nickfedor.com/v1.13.0/)
* [run aio image using podman](https://github.com/nextcloud/all-in-one/discussions/5090) but this gives the _wrong_ answer
* [Rootless Podman Quadlet](https://github.com/nextcloud/all-in-one/discussions/3487)
* [[Feature Request] Support for Podman](https://github.com/containrrr/watchtower/issues/1060) on the now archived original watchtower repo

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

## podman network

aio_default comes (and goes) with mastercontainer.

```bash
$ podman network inspect aio_default
[
     {
          "name": "aio_default",
          "id": "846fbcdee5e101e9d670c0b905ae9708eb3abfcdc4194478ebbe8ad64b08b316",
          "driver": "bridge",
          "network_interface": "podman1",
          "created": "2025-02-01T20:20:12.119599101+01:00",
          "subnets": [
               {
                    "subnet": "10.89.0.0/24",
                    "gateway": "10.89.0.1"
               }
          ],
          "ipv6_enabled": false,
          "internal": false,
          "dns_enabled": true,
          "labels": {
               "com.docker.compose.network": "default",
               "com.docker.compose.project": "aio",
               "com.docker.compose.version": "2.30.3"
          },
          "options": {
               "isolate": "true"
          },
          "ipam_options": {
               "driver": "host-local"
          },
          "containers": {
               "0fed36cb5567dc205d736a8392b3ab06106ff26953d5bbc35302eec75713b0ea": {
                    "name": "nextcloud-aio-mastercontainer",
                    "interfaces": {
                         "eth0": {
                              "subnets": [
                                   {
                                        "ipnet": "10.89.0.2/24",
                                        "gateway": "10.89.0.1"
                                   }
                              ],
                              "mac_address": "ee:7d:3d:b0:36:22"
                         }
                    }
               }
          }
     }
]
```

nextcloud-aio seems to be (more?) permanent.

```bash
$ podman network inspect nextcloud-aio
[
     {
          "name": "nextcloud-aio",
          "id": "787f767a05e0f8458b53026d120e0d18160efeb0f7ca87524f3c63afd6934841",
          "driver": "bridge",
          "network_interface": "podman2",
          "created": "2025-02-01T20:03:54.904234854+01:00",
          "subnets": [
               {
                    "subnet": "10.89.1.0/24",
                    "gateway": "10.89.1.1"
               }
          ],
          "ipv6_enabled": false,
          "internal": false,
          "dns_enabled": true,
          "options": {
               "isolate": "true"
          },
          "ipam_options": {
               "driver": "host-local"
          },
          "containers": {
               "0b3dd8da08bccdcc6357a104646e08b43b35e2f4333b2c420b476c21fcdd9157": {
                    "name": "nextcloud-aio-notify-push",
                    "interfaces": {
                         "eth0": {
                              "subnets": [
                                   {
                                        "ipnet": "10.89.1.13/24",
                                        "gateway": "10.89.1.1"
                                   }
                              ],
                              "mac_address": "3a:f3:f3:aa:6d:d2"
                         }
                    }
               },
               "0fed36cb5567dc205d736a8392b3ab06106ff26953d5bbc35302eec75713b0ea": {
                    "name": "nextcloud-aio-mastercontainer",
                    "interfaces": {
                         "eth1": {
                              "subnets": [
                                   {
                                        "ipnet": "10.89.1.9/24",
                                        "gateway": "10.89.1.1"
                                   }
                              ],
                              "mac_address": "2a:55:42:69:f6:6d"
                         }
                    }
               },
               "1a9360490d62ab39dfc2a4842943ea4c498d09e8029ad8cb8f681245747d5488": {
                    "name": "nextcloud-aio-database",
                    "interfaces": {
                         "eth0": {
                              "subnets": [
                                   {
                                        "ipnet": "10.89.1.10/24",
                                        "gateway": "10.89.1.1"
                                   }
                              ],
                              "mac_address": "a6:9e:53:c7:e1:b2"
                         }
                    }
               },
               "5340ed7546130d0cd66baa7fa3a4e3ec7cc8127a06c77c0d72360d585192c3c0": {
                    "name": "nextcloud-aio-nextcloud",
                    "interfaces": {
                         "eth0": {
                              "subnets": [
                                   {
                                        "ipnet": "10.89.1.12/24",
                                        "gateway": "10.89.1.1"
                                   }
                              ],
                              "mac_address": "82:f5:f8:44:86:6e"
                         }
                    }
               },
               "6a5638343adf014a5c21ef7a438099659674eb2b2da7c2da2f19d199617d0365": {
                    "name": "nextcloud-aio-redis",
                    "interfaces": {
                         "eth0": {
                              "subnets": [
                                   {
                                        "ipnet": "10.89.1.11/24",
                                        "gateway": "10.89.1.1"
                                   }
                              ],
                              "mac_address": "6e:e0:8d:86:53:57"
                         }
                    }
               },
               "a431d34e4c85959906c7a2526f6862e9f6ffcac0fd1f4d6736b6fe69395464e7": {
                    "name": "nextcloud-aio-apache",
                    "interfaces": {
                         "eth0": {
                              "subnets": [
                                   {
                                        "ipnet": "10.89.1.14/24",
                                        "gateway": "10.89.1.1"
                                   }
                              ],
                              "mac_address": "2a:99:4d:21:4c:7e"
                         }
                    }
               }
          }
     }
]
```

```bash
$ podman network inspect aio_nextcloud-aio
[
     {
          "name": "aio_nextcloud-aio",
          "id": "51e64b089f681ec86bac7b2e6d7d7afc4000326839ffcd90d1cb1d3c25cb76aa",
          "driver": "bridge",
          "network_interface": "podman1",
          "created": "2025-02-01T20:55:02.131755354+01:00",
          "subnets": [
               {
                    "subnet": "10.89.0.0/24",
                    "gateway": "10.89.0.1"
               }
          ],
          "ipv6_enabled": false,
          "internal": false,
          "dns_enabled": true,
          "labels": {
               "com.docker.compose.network": "nextcloud-aio",
               "com.docker.compose.project": "aio",
               "com.docker.compose.version": "2.30.3"
          },
          "options": {
               "isolate": "true"
          },
          "ipam_options": {
               "driver": "host-local"
          },
          "containers": {
               "31171355e20ecc0cd9c67378f4b90512a6c981a028a58d3e25a1063cce5567c1": {
                    "name": "nextcloud-aio-mastercontainer",
                    "interfaces": {
                         "eth0": {
                              "subnets": [
                                   {
                                        "ipnet": "10.89.0.2/24",
                                        "gateway": "10.89.0.1"
                                   }
                              ],
                              "mac_address": "2e:ff:14:6a:71:c5"
                         }
                    }
               }
          }
     }
]
```

```bash
```


## mastercontainer

### php code

```bash
$ sudo dnf install composer php-sodium php-pecl-apcu-devel
$ cd php
$ composer install
```

## coredns

* [coredns](https://github.com/coredns/coredns)
* [Running CoreDNS as a DNS Server in a Container](https://dev.to/robbmanes/running-coredns-as-a-dns-server-in-a-container-1d0)
* [Add support for CloudFlare's new 1.1.1.1 DNS-over-HTTPS service](https://github.com/coredns/coredns/issues/1650)
