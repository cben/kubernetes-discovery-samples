#!/bin/bash
# Usage:
#     tools/diff-interesting.sh kubernetes-vA.B.C/ kubernetes-vX.Y.Z/
# or:
#     git difftool --dir-diff --extcmd=tools/diff-interesting.sh
#
diff --recursive --unified=1 --color \
     --ignore-matching-lines=serverAddress \
     --ignore-matching-lines='^\* Connected to ' \
     --ignore-matching-lines='^\*   Trying ' \
     --ignore-matching-lines='^\*   CAfile:' \
     --ignore-matching-lines='^\*  subject:' \
     --ignore-matching-lines='^\*  start date:' \
     --ignore-matching-lines='^\*  expire date:' \
     --ignore-matching-lines='^\*  issuer:' \
     --ignore-matching-lines='^\*  SSL certificate verify ' \
     --ignore-matching-lines='^\* Using Stream ID:' \
     --ignore-matching-lines='^\* Connection #[0-9]* to host ' \
     --ignore-matching-lines='^\(> \)\?[Hh]ost:' \
     --ignore-matching-lines='^\(< \)\?[Dd]ate:' \
     --ignore-matching-lines='^\(< \)\?[Ll]ast-[Mm]odified' \
     --ignore-matching-lines='^\(> \)\?[Uu]ser-[Aa]gent:' \
     --ignore-matching-lines='^\(< \)\?[Cc]ontent-[Ll]ength:' \
     --ignore-matching-lines='^\(< \)\?[Aa]udit-[Ii]d:' \
     --ignore-matching-lines='--:--:--' \
     --ignore-matching-lines='[}{] \[[0-9]* bytes data\]' \
     "$@"
