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
     --ignore-matching-lines='^< Date:' \
     --ignore-matching-lines='^< Content-Length:' \
     --ignore-matching-lines='--:--:--' \
     --ignore-matching-lines='{ \[[0-9]* bytes data\]' \
     "$@"
