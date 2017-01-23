#! /bin/bash

set -e

usage() {
    echo "Usage: $0 -p <PACK> -u <USER> [-f <FILE>] [-i <IP>] [...options]"
    echo ""
    echo "  -f      Json file to use. Defaults to 'main.json'"
    echo "  -i      IP of the machine"
    echo "  -p      pack"
    echo "  -P      password (default=ubuntu)"
    echo "  -U      initial ssh user (default=ubuntu)"
    echo "  -u      user"
    echo "  -h      optional hostname to set"
    echo ""
    exit 1
}

FILE=main.json
SSH_USER=ubuntu
PASS=ubuntu
HOST=
PACK=
USER=
while getopts ":f:i:u:p:P:U:h:" o; do
    case "${o}" in
        f)
            FILE="$OPTARG"
            ;;
        i)
            IP="$OPTARG"
            ;;
        U)
            SSH_USER="$OPTARG"
            ;;
        P)
            PASS="$OPTARG"
            ;;
        u)
            USER="$OPTARG"
            ;;
        p)
            PACK="$OPTARG"
            ;;
        h)
            HOST="$OPTARG"
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

[[ -z "$PACK" ]] && { echo "Missing pack choice"; usage; exit 1; }
[[ ! -f "packs/$PACK/$FILE" ]] && { echo "json file \"$FILE\" does not exist in packs/$PACK"; exit 2; }

[[ -z "$USER" ]] && { echo "Missing user"; usage; exit 1; }

cd "packs/$PACK"

echo "packer build -force -only=\"null\" -var \"ip=$IP\" -var \"ssh_user=$SSH_USER\" -var \"ssh_pass=$PASS\" -var \"host=$HOST\" -var \"user=$USER\" \"$FILE\""
 
packer build -force -only="null" -var "ip=$IP" -var "ssh_user=$SSH_USER" -var "ssh_pass=$PASS" -var "host=$HOST" -var "user=$USER" "$FILE"






