#! /bin/bash

sudo rm /tmp/id_rsa* 2>/dev/null || true
[[ -f /tmp/bash_aliases ]] && sudo rm /tmp/bash_aliases

exit 0