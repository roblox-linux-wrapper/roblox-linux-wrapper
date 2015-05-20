#!/bin/bash

if [[ "$(basename $(pwd))" == "debian" ]]; then
	cd ..
fi

if [[ -d ".git" ]]; then
	VERSION=$(git describe --tags | sed 's/^v//' | sed 's/-/+/g')
	BRANCH=$(git rev-parse --abbrev-ref HEAD)
	BUILD_MESSAGE="Build Git branch ${BRANCH} revision ${VERSION}."
	dch -v "${VERSION}" --distribution unstable "${BUILD_MESSAGE}"
	git commit --author="RLW Automatic Builder <packages-admin@overdrive.pw>" debian/changelog -m "${BUILD_MESSAGE}"
else
	printf '%b\n' 'Must be in Git tree to update version automatically.'
fi
