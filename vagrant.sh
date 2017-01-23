#!/bin/bash

set -e

usage() {
    echo "Usage: $0 -p <PACK> -U <USER> [-b] [-f <FILE>] [-v <VERSION>]" 1>&2
    echo "" 1>&2
    echo "  -b              Skip rebuilding the box" 1>&2;
    echo "  -f              Specify the json file. Defaults to 'main.json'" 1>&2;
    echo "  -p <PACK>       Pack (required)" 1>&2;
    echo "  -u <USER>       Custom user (required)" 1>&2;
    echo "  -v <VERSION>    Version the build" 1>&2;
    echo "" 1>&2
    exit 1
}

REBUILD=TRUE
VERSION=
FILE="main.json"
USER=
while getopts ":bf:v:U:p:" o; do
    case "${o}" in
        b)
            REBUILD=
            ;;
        f)
            FILE="$OPTARG"
            ;;
        v)
            VERSION="$OPTARG"
            ;;
        U)
            USER="$OPTARG"
            ;;
        p)
            PACK="$OPTARG"
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))


[[ -z "$PACK" ]] && { echo "Missing pack choice"; usage; exit 1; }
[[ -z "$USER" ]] && { echo "Missing user"; usage; exit 1; }

[[ ! -f "packs/$PACK/$FILE" ]] && { echo "json file \"$FILE\" does not exist in packs/$PACK"; exit 2; }


VPACK="$PACK"
VBOX="smc-$PACK"
if [[ -n "$VERSION" ]]; then
    VPACK="$VPACK-$VERSION"
    VBOX="$VBOX-$VERSION"
fi


if [ ! -f "builds/$VBOX.box" ]; then
    [[ -n $REBUILD ]] && echo "Box does not exist. Must build."
    REBUILD=TRUE
fi

if [ -n $REBUILD ]; then
    echo "- Building the Box"
    [[ -f "builds/$VBOX.box" ]] && rm "builds/$VBOX.box"
    cd "packs/$PACK"
    echo "packer build -force -only=virtualbox-iso -var \"boxname=$VBOX\" -var \"user=$USER\" \"$FILE\""
    packer build -force -only=virtualbox-iso -var "boxname=$VBOX" -var "user=$USER" "$FILE"
    cd -
else
    echo "- Skipping box build"
fi

echo "- Reloading Vagrant"
vagrant plugin install vagrant-vbguest
[[ -n `vagrant box list | grep "smc/$VPACK "` ]] && vagrant box remove "smc/$VPACK" || true
vagrant box add "smc/$VPACK" "builds/$VBOX.box"


echo "- $PACK vagrant box installed: smc/$VPACK"
