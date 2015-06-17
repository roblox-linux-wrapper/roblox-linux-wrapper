#!/bin/bash

if [[ "$(basename $(pwd))" == "debian" ]]; then
	cd ..
fi

if [[ -d ".git" ]]; then
	if [[ "$1" == "commit" ]]; then
		VERSION=$(date "+%Y.%m.%d")
	else
		VERSION=$(git describe --tags | sed 's/^v//' | sed 's/-/+/g')
	fi
	BRANCH=$(git rev-parse --abbrev-ref HEAD)
	BUILD_MESSAGE="Build Git branch ${BRANCH} revision ${VERSION}."
	dch -v "${VERSION}" --distribution unstable "${BUILD_MESSAGE}"
	if [[ "$1" == "commit" ]]; then
		git commit --author="RLW Automatic Builder <packages-admin@overdrive.pw>" debian/changelog -m "${BUILD_MESSAGE}"
		printf '%b\n' "Tagging as ${VERSION}."
		git tag -f "${VERSION}"
	fi
else
	printf '%b\n' 'Must be in Git tree to update version automatically.'
fi
