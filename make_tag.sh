#!/bin/sh

# make the release tag
git tag -a $1 -m "$1 release"

# push the tags to GitHub
git push origin --tags
