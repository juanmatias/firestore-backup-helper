# Firebase Backup

This is a small helper to perform Firebase backups.

## From help

```
Firebase backup helper
Usage: ./firestore-backup.sh [--credentials <arg>] [--collections <arg>]
    [--rotation-days <arg>] [--(no-)quiet]
    [--(no-)dry-run] [-h|--help]
    <project> <region> <bucket-address> <service-account>
    <project>: Poject name
    <region>: Region
    <bucket-address>: Bucket address, e.g. gs://project-backup-bucket/
    <service-account>: Service account to use, must have export access on
        firestore and write access on bucket
    --credentials: Auth credentials file absolute path and name, defaults to
        $(pwd)/credentials.json (no default)
    --collections: Collections to be exported, can be blank (no default)
    --rotation-days: Rotation days, e.g. 30 indicates that when doing a new
        backup, those older than 30 days will be deleted. If no flag then
        deletion is disabled (no default)
    -h, --help: Prints help
```

## Meta data
Author:Kungfoo
