#! /bin/bash

## # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
#     CLI Args
#

set -e
usage() {
    echo "Usage: $0 -i <PROJECT_ID> -p <PACK> -f <FILE> -v <VERSION> -c <CONFIG_FILE> -u <USER_FILE>" 1>&2;
    echo "" 1>&2;
    echo "  -c <CONFIG_FILE   Specify the config file. (Default: ./vagrant.conf)" 1>&2;
    echo "  -f <JSON_FILE>    Specify the json file inside the pack. (Default: main.json)" 1>&2;
    echo "  -i <ID>           Specify a project ID" 1>&2;
    echo "  -p <PACK>         Pack. (Default: ubuntu)" 1>&2;
    echo "  -u <USER_FILE>    User Config File. (Default: ./user.conf)" 1>&2;
    echo "  -v <VERSION>      Version the build" 1>&2;
    echo "" 1>&2;
    exit 1;
}

VERSION=
FILE="main.json"
PACK="ubuntu"
CONFIG_FILE="vagrant.conf"
USER_FILE="user.conf"
PROJECT_ID=

while getopts ":c:f:v:u:p:i:" o; do
    case "${o}" in
        f)
            FILE="$OPTARG"
            ;;
        i)
            PROJECT_ID="$OPTARG"
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

USER=
SSH_KEY=

. "$CONFIG_FILE"
. "$USER_FILE"

[[ -z "$USER" ]] && { echo "Missing user" 1>&2; CONFIG_MISSING=true; }
[[ -z "$SSH_KEY" ]] && { echo "Missing user's public ssh key" 1>&2; CONFIG_MISSING=true;  }

[[ -z "$CONFIG_MISSING" ]] || { echo "Config missing from config file." 1>&2; usage; exit 1; }



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


if [ ! -f "builds/$VBOX.box" ]; then
    [[ -n $REBUILD ]] && echo "Box does not exist. Must build."
    REBUILD=TRUE
fi

if [ -n $REBUILD ]; then
    echo "- Building the Box"
    [[ -f "builds/$VBOX.box" ]] && rm "builds/$VBOX.box"
    cd "packs/$PACK"
    echo "packer build -force -only=virtualbox-iso -var \"boxname=$VBOX\" -var \"user=$USER\" -var \"ssh_key=$SSH_KEY\"  \"$FILE\""
    packer build -force -only=virtualbox-iso -var "boxname=$VBOX" -var "user=$USER" -var "ssh_key=$SSH_KEY"  "$FILE"
    cd -
else
    echo "- Skipping box build"
fi

echo "- Reloading Vagrant"
vagrant plugin install vagrant-vbguest
[[ -n `vagrant box list | grep "$PROJECT_ID/$VPACK "` ]] && vagrant box remove "$PROJECT_ID/$VPACK" || true
vagrant box add "$PROJECT_ID/$VPACK" "builds/$VBOX.box"


echo "- $PACK vagrant box installed: $PROJECT_ID/$VPACK"
