#! /bin/bash

## # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
#     CLI Args
#

set -e
usage() {
    echo "Usage: $0 -i <PROJECT_ID> -p <PACK> -f <FILE> -v <VERSION> -c <CONFIG_FILE> -u <USER_FILE>" 1>&2
    echo "" 1>&2
    echo "  -c <CONFIG_FILE   Specify the config file. (Default: ./amazon.conf)" 1>&2;
    echo "  -f <JSON_FILE>    Specify the json file inside the pack. (Default: main.json)" 1>&2;
    echo "  -i <ID>           Specify a project ID" 1>&2;
    echo "  -p <PACK>         Pack. (Default: ubuntu)" 1>&2;
    echo "  -s <SIZE>         Instance size. (Default: t2.micro)" 1>&2;
    echo "  -u <USER_FILE>    User Config File. (Default: ./user.conf)" 1>&2;
    echo "  -v <VERSION>      Version the build" 1>&2;
    echo "" 1>&2
    exit 1
}

VERSION=
FILE="main.json"
PACK="ubuntu"
CONFIG_FILE="amazon.conf"
USER_FILE="user.conf"

INSTANCE_SIZE=
PROJECT_ID=

while getopts ":c:f:v:u:p:s:i:" o; do
    case "${o}" in
        i)
            PROJECT_ID="$OPTARG"
            ;;
        s)
            INSTANCE_SIZE="$OPTARG"
            ;;
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

[[ -z "$PROJECT_ID" ]] && { echo "Missing project ID" 1>&2; ARGS_MISSING=true; }
[[ -z "$PACK" ]] && { echo "Missing pack choice" 1>&2; ARGS_MISSING=true; }
[[ -z "$VERSION" ]] && { echo "Missing version" 1>&2; ARGS_MISSING=true; }
[[ -z "$CONFIG_FILE" ]] && { echo "Missing config file" 1>&2; ARGS_MISSING=true; }

[[ -z "$ARGS_MISSING" ]] || { echo "Args missing." 1>&2; usage; exit 1; }

[[ ! -f "$CONFIG_FILE" ]] && { echo "Config file $CONFIG_FILE does not exist" 1>&2; FILES_MISSING=true; }
[[ ! -f "$USER_FILE" ]] && { echo "User config file does not exist" 1>&2; FILES_MISSING=true; }
[[ ! -f "packs/$PACK/$FILE" ]] && { echo "Json file \"$FILE\" does not exist in packs/$PACK" 1>&2; FILES_MISSING=true; }

[[ -z "$FILES_MISSING" ]] || { echo "Files missing." 1>&2; usage; exit 1; }

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

[[ -z "$CONFIG_MISSING" ]] || { echo "Config missing from config file."; usage; exit 1; }

[[ -n "$INSTANCE_SIZE" ]] && SIZE="$INSTANCE_SIZE"
[[ -z "$SIZE" ]] && SIZE="t2.micro"


## # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
#     Vars
#


VPACK="$PACK"
VBOX="$PROJECT_ID-$PACK"
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
echo "packer build -force -only=amazon-ebs -var \"boxname=$VBOX\" -var \"instancesize=$SIZE\" -var \"user=$USER\" -var \"ssh_key=$SSH_KEY\" -var \"aws_access=$AWS_ACCESS\" -var \"aws_secret=$AWS_SECRET\" \"$FILE\""
packer build -force -only=amazon-ebs -var "boxname=$VBOX" -var "instancesize=$SIZE" -var "user=$USER" -var "ssh_key=$SSH_KEY" -var "aws_access=$AWS_ACCESS" -var "aws_secret=$AWS_SECRET" "$FILE"
cd -