#!/bin/bash

# m4_ignore(
echo "This is just a script template, not the script (yet) - pass it to 'argbash' to fix this." >&2
exit 11  #)Created by argbash-init v2.9.0
# ARG_OPTIONAL_SINGLE([credentials],,[Auth credentials file absolute path and name, defaults to \$(pwd)/credentials.json])
# ARG_OPTIONAL_SINGLE([collections],,[Collections to be exported, can be blank])
# ARG_OPTIONAL_SINGLE([rotation-days],,[Rotation days, e.g. 30 indicates that when doing a new backup, those older than 30 days will be deleted. If no flag then deletion is disabled])
# ARG_OPTIONAL_BOOLEAN([quiet])
# ARG_OPTIONAL_BOOLEAN([dry-run])
# ARG_POSITIONAL_SINGLE([project],[Poject name])
# ARG_POSITIONAL_SINGLE([region],[Region])
# ARG_POSITIONAL_SINGLE([bucket-address],[Bucket address, e.g. gs://project-backup-bucket/])
# ARG_POSITIONAL_SINGLE([service-account],[Service account to use, must have export access on firestore and write access on bucket])
# ARG_DEFAULTS_POS
# ARG_HELP([Firebase backup helper])
# ARGBASH_GO

# [ <-- needed because of Argbash

say () {
	if [ "$_arg_quiet" = "off" ];
	then
		printf "%s\\n" "$1"
	fi
}

run () {
	if [ "$_arg_dry_run" = "off" ];
	then
		eval "$1"
    else
        say "Dry-run enabled [CMD]: $1"
	fi
}

REGEX_BUCKET_NAME="^gs://[a-zA-Z0-9\-]*/[_\:0-9A-Z\-]*/$"
REGEX_OBJECT_DATE="^gs://[a-zA-Z0-9\-]*/([0-9\-]*)T[_\:0-9]*/$"
[ -z $_arg_credentials ] && _arg_credentials=$(pwd)"/credentials.json"


gcloud_auth () {
    CMD="gcloud auth activate-service-account $_arg_service_account --key-file=$_arg_credentials"
    run "$CMD"
    if [ $? -ne 0 ];
    then
        die "Can't log into gcloud"
    fi
}

export () {
    local collections=""
    if [ ! -z $_arg_collections ];
    then
        collections="--collection-ids="$_arg_collections
    fi
    CMD="gcloud firestore export $_arg_bucket_address --project $_arg_project $collections"
    run "$CMD"
    if [ $? -ne 0 ];
    then
        die "Can't export"
    fi

}

get_objects () {
    CMD="gsutil ls $_arg_bucket_address"
    run "$CMD"
}

evaluate_object_2b_deleted () {
    if [[ "$1" =~ $REGEX_BUCKET_NAME ]];
    then
        DATE=$(echo $1 | sed -E 's|'$REGEX_OBJECT_DATE'|\1|')
        if [ "$DATE" = "$1" ];
        then
            die "Can't extract date"
        fi
        DIFF=$(( ($(date +"%s") - $(date -d $DATE +"%s") )/(60*60*24) ))
        if [ $DIFF -gt $_arg_rotation_days ];
        then
            echo $DIFF
        else
            echo 0
        fi
    else
        die "Name $1 does not match $REGEX_BUCKET_NAME"
    fi
}

delete () {
    say "deleting $1..."
    say "gsutil rm -r $1"
}

say "Login..."
gcloud_auth

say "Exporting..."
export

if [ ! -z $_arg_rotation_days ];
then
    say "doing"
    O=$(get_objects)
	if [ "$_arg_dry_run" = "off" ];
    then
        for o in $O;
        do
            if [ $(evaluate_object_2b_deleted $o) -ne 0 ];
            then
                delete $o
            else
                say "$o won't be deleted"
            fi
        done
    fi
fi

# ] <-- needed because of Argbash
