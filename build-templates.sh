#!/bin/bash

export PATH="${PATH}:$(dirname ${0})/node_modules/.bin"

if ! which coffeekup; then
    echo "can't find coffeekup."
    exit 1
fi

for t in public/*_template.coffee; do
    coffeekup --js "${t}" || exit 1
done
