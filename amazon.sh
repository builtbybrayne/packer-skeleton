#! /bin/bash

set -e
usage() {
    echo "Usage: $0 [-f <FILE>] [-v <VERSION>] PACK" 1>&2
    echo "" 1>&2
    echo "  -s              Instance size. e.g. t2.small. Required" 1>&2;
    echo "  -f              Specify the json file. Defaults to 'main.json'" 1>&2;
    echo "  -p              pack"
    echo "  -u              custom user"
    echo "  -v <VERSION>    Version the build" 1>&2;
    echo "" 1>&2
    exit 1
}

VERSION=
FILE="main.json"
SIZE=
PACK=
CUSTOM_USER=
while getopts ":f:v:s:p:u:" o; do
    case "${o}" in
        f)
            FILE="$OPTARG"
            ;;
        p)
            PACK="$OPTARG"
            ;;
        s)
            SIZE="$OPTARG"
            ;;
        u)
            CUSTOM_USER="$OPTARG"
            ;;
        v)
            VERSION="$OPTARG"
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))
PACK="$1"

[[ -z "$PACK" ]] && { echo "Missing pack choice" 1>&2; usage; exit 1; }
[[ -z "$CUSTOM_USER" ]] && { echo "Missing custom user" 1>&2; usage; exit 1; }

[[ -z "$SIZE" ]] && { echo "Need an instance size. e.g. t2.small" 1>&2; usage; exit 2; }

[[ ! -f "packs/$PACK/$FILE" ]] && { echo "json file \"$FILE\" does not exist in packs/$PACK" 1>&2; exit 2; }


VPACK="$PACK"
VBOX="smc-$PACK"
if [[ -n "$VERSION" ]]; then
    VPACK="$VPACK-$VERSION"
    VBOX="$VBOX-$VERSION"
fi

echo "- Building the AMI"
[[ -f "builds/$VBOX.box" ]] && rm "builds/$VBOX.box"
cd "packs/$PACK"
if [ -f "prep.sh" ]; then
    ./prep.sh
fi
echo "packer build -force -only=amazon-ebs -var \"boxname=$VBOX\" -var \"custom_user=$CUSTOM_USER\" \"$FILE\""
packer build -force -only=amazon-ebs -var "boxname=$VBOX" -var "instancesize=$SIZE" -var "custom_user=$CUSTOM_USER" "$FILE"
cd -