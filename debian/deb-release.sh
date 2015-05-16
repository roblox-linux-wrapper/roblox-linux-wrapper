#!/bin/bash

if [[ "$(basename $(pwd))" == "debian" ]]; then
	cd ..
fi

if [[ -d ".git" ]]; then
	VERSION=$(git describe --tags | sed 's/^v//' | sed 's/-/+/g')
	dch -v "${VERSION}" --distribution unstable "Automatic build."
else
	printf '%b\n' 'Must be in Git tree to update version automatically.'
fi
