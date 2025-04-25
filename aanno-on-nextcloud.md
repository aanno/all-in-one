# aanno's on nextcloud

## tips and tricks

### phone region

```bash
occ config:system:set default_phone_region --value="DE
```

* [set phone region](https://help.nextcloud.com/t/standard-telefonregion-festlegen/140694)
* [list of phone regions](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2#Officially_assigned_code_elements)

## testing

* [notify_push](https://github.com/nextcloud/notify_push)
* [How to debug problems with Collabora and/or Talk](https://github.com/nextcloud/all-in-one/discussions/1358)

## Known Bugs

### Problems in OneCalendar

* [Bug]: Caldav limit tag on initial sync causes incorrect Caldav error response](https://github.com/nextcloud/server/issues/48678)

### Warning suspicious_login Could not predict suspiciousness

Means: training is still ongoing

* [Warning suspicious_login Could not predict suspiciousness](https://github.com/nextcloud/suspicious_login/issues/197)
