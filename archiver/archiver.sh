#!/bin/bash

set -e

# workaround as cloud run volume mounts don't appear to have posix permission controls
printf "%s" "$ARCHIVER_SSH_KEY" > /ARCHIVER_SSH_KEY
chmod 600 /ARCHIVER_SSH_KEY
export GIT_SSH_COMMAND="ssh -i /ARCHIVER_SSH_KEY -o StrictHostKeychecking=no"

DIR_LOCAL_BIN=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
DIR_TMP=$(mktemp -d /tmp/tsArchive.XXXXXXX)
DIR_REPO=$DIR_TMP/record

git clone -v $ARCHIVE_REPO_GH $DIR_REPO
cd $DIR_REPO
git rm *.json

python3 $DIR_LOCAL_BIN/archiver.py pullnew $DIR_REPO

if [[ -n $(find $DIR_REPO -type f -name '*.json' ! -name .timestamps.json -print -quit) ]]; then

    git config user.name "Timestamp Bot"
    git config user.email timestamp.bot

    cp /timestamping/hooks/post-commit.local .git/hooks/post-commit

    git add *.json
    git commit -m 'added timestmaps'
    git push

    python3 $DIR_LOCAL_BIN/archiver.py clearnew
fi
