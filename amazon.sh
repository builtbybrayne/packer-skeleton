#! /bin/bash

## # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
#     CLI Args
#

set -e
usage() {
    echo "Usage: $0 -p <PACK> -f <FILE> -v <VERSION> -c <CONFIG_FILE> -u <USER_FILE>" 1>&2
    echo "" 1>&2
    echo "  -c <CONFIG_FILE   Specify the config file. (Default: vagrant.conf)" 1>&2;
    echo "  -f <JSON_FILE>    Specify the json file inside the pack. Defaults to 'main.json'" 1>&2;
    echo "  -p <PACK>         Pack" 1>&2;
    echo "  -u <USER_FILE>    User Config File. (Default: ./user.conf)" 1>&2;
    echo "  -v <VERSION>      Version the build" 1>&2;
    echo "" 1>&2
    exit 1
}

VERSION=
FILE="main.json"
PACK=
CONFIG_FILE="amazon.conf"
USER_FILE="user.conf"

while getopts ":c:f:v:u:p:" o; do
    case "${o}" in
        f)
            FILE="$OPTARG"
            ;;
        p)
            PACK="$OPTARG"
            ;;
        c)
            CONFIG_FILE="$OPTARG"
            ;;
        u)
            USER_FILE="$OPTARG"
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

[[ -z "$PACK" ]] && { echo "Missing pack choice" 1>&2; ARGS_MISSING=true }
[[ -z "$VERSION" ]] && { echo "Missing version" 1>&2; ARGS_MISSING=true }
[[ -z "$CONFIG_FILE" ]] && { echo "Missing config file" 1>&2; ARGS_MISSING=true }

[[ -z "$ARGS_MISSING" ]] || { echo "Args missing."; usage; exit 1; }

[[ ! -f "$CONFIG_FILE" ]] && { echo "Config file $CONFIG_FILE does not exist" 1>&2; FILES_MISSING=true; }
[[ ! -f "$USER_FILE" ]] && { echo "User config file does not exist" 1>&2; FILES_MISSING=true; }
[[ ! -f "packs/$PACK/$FILE" ]] && { echo "Json file \"$FILE\" does not exist in packs/$PACK" 1>&2; FILES_MISSING=true; }

[[ -z "$FILES_MISSING" ]] || { echo "Files missing."; usage; exit 1; }

## # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
#     Config Args
#


SIZE=
AWS_ACCESS=
AWS_SECRET=

USER=
SSH_KEY=

. "$CONFIG_FILE"
. "$USER_FILE"

[[ -z "$USER" ]] && { echo "Missing user" 1>&2; CONFIG_MISSING=true; }
[[ -z "$SSH_KEY" ]] && { echo "Missing user's public ssh key"; CONFIG_MISSING=true;  }
[[ -z "$AWS_ACCESS" ]] && { echo "Missing AWS Access Key" 1>&2; CONFIG_MISSING=true;  }
[[ -z "$AWS_SECRET" ]] && { echo "Missing AWS Secret Key's public ssh key"; CONFIG_MISSING=true;  }
[[ -z "$SIZE" ]] && { echo "Need an instance size. e.g. t2.small" 1>&2; CONFIG_MISSING=true;  }

[[ -z "$CONFIG_MISSING" ]] || { echo "Config missing from config file."; usage; exit 1; }


## # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
#     Vars
#


VPACK="$PACK"
VBOX="osimg-$PACK"
if [[ -n "$VERSION" ]]; then
    VPACK="$VPACK-$VERSION"
    VBOX="$VBOX-$VERSION"
fi



## # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
#     Build
#


echo "- Building the AMI"
[[ -f "builds/$VBOX.box" ]] && rm "builds/$VBOX.box"
cd "packs/$PACK"
if [ -f "prep.sh" ]; then
    ./prep.sh
fi
echo "packer build -force -only=amazon-ebs -var \"boxname=$VBOX\" -var \"user=$USER\" -var \"ssh_key=$SSH_KEY\" -var \"aws_access=$AWS_ACCESS\" -var \"aws_secret=$AWS_SECRET\" \"$FILE\""
packer build -force -only=amazon-ebs -var "boxname=$VBOX" -var "instancesize=$SIZE" -var "user=$USER" -var "ssh_key=$SSH_KEY" -var "aws_access=$AWS_ACCESS" -var "aws_secret=$AWS_SECRET" "$FILE"
cd -