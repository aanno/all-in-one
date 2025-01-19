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
