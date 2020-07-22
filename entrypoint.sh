#!/bin/bash

CURRENTDIR=$(pwd)
WORKDIR=$(mktemp -d)

# clone repository
echo "Clone destination repo"

git config --global user.email "$GITHUB_USER_EMAIL"
git config --global user.name "$GITHUB_USER_NAME"
git clone "https://$INPUT_GITHUB_TOKEN@github.com/$INPUT_DESTINATION_REPOSITORY.git" "$WORKDIR"

function copy() {
    source="$CURRENTDIR/$1"
    destination="$WORKDIR/$2"

    if [[ -d "$source" ]]; then
        ls -lah $source
        ls "$destination" || mkdir -p "$destination"
        rm -r "$destination"/
        echo "copying content of $source to $destination"
        cp -r "$source"/. "$destination"
        ls -lah $destination
    elif [[ -f "$source" ]]; then
        ls -lah `dirname $source`
        destination_dir=`dirname $destination`
        ls "$destination_dir" || mkdir -p "$destination_dir"
        echo "copying file $source to $destination"
        cp "$source" "$destination"
        ls -lah `dirname $destination`
    else
        echo "invalid path $source"
    fi

    echo '---'
}

# perform copying
echo "Copy operations"

set -f
ops=(${INPUT_COPY_OPERATIONS// / })
for e in "${ops[@]}"
do
    echo "entry $e"
    pair=(${e//:/ })
    len=${#pair[@]}
    if [ $len -eq 2 ]; then
        copy "${pair[0]}" "${pair[1]}"
    else
        echo "invalid copy_operations argument - should be in form of: 'config.yaml:config/default.yml templates:tmpls'"
        exit 1
    fi
done

# push changes to the other repository
echo "Push changes"

cd "$WORKDIR"
git remote -v
git add .
git commit -m "Copied from (https://github.com/$GITHUB_REPOSITORY/commit/$GITHUB_SHA)"
git push origin master
