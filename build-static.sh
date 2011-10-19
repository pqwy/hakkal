#!/bin/bash

export PATH="${PATH}:$(dirname ${0})/node_modules/.bin"

function ck_warez() {
    if ! which "${1}" &> /dev/null; then
        echo "can't find ${1}..."
        exit 1
    fi
}
ck_warez 'coffeekup'
ck_warez 'coffee'

for t in public/*.coffee; do
    case "${t}" in
        *template.coffee)
            coffeekup --js "${t}" || exit 1
            echo -e "[template]\t${t}"
            ;;
        *.coffee)
            coffee -c "${t}" || exit 1
            echo -e "[script]\t${t}"
            ;;
    esac
done
