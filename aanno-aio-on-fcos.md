# aanno's aio-on-focos

This is a compose file for podman especially for FCOS.

Copy `env.template` and adapt it to your needs.

Status:

* Work-around for configs property (as configs properties are currently _not_ supported by podman)
* Currently running on 'local' domain of your choice
  + setup works
  + https://nextcloud.my.local/ (AIO_DOMAIN) works
  + local base domains works
  + other sub domains do _not_ working locally (as there is no wildcard cert)

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
