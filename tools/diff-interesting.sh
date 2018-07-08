#!/bin/bash
# Usage:
#
#     git difftool --dir-diff --extcmd=tools/diff-interesting.sh
#
diff --recursive --unified=1 --color \
     --ignore-matching-lines=serverAddress \
     --ignore-matching-lines='^\*  subject:' \
     --ignore-matching-lines='^\*  start date:' \
     --ignore-matching-lines='^\*  expire date:' \
     --ignore-matching-lines='^\*  issuer:' \
     --ignore-matching-lines='^\* Using Stream ID:' \
     --ignore-matching-lines='^< [Dd]ate:' \
     --ignore-matching-lines='^< [Ll]ast-[Mm]odified' \
     --ignore-matching-lines='^< [Cc]ontent-[Ll]ength:' \
     --ignore-matching-lines='--:--:--' \
     --ignore-matching-lines='{ \[[0-9]* bytes data\]' \
     "$@"
