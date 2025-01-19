#!/bin/bash -x

podman exec -it --user www-data nextcloud-aio-nextcloud php /var/www/html/occ $*


