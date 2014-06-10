#!/bin/sh

# make release development branch
git branch $1

# push branch to GitHub
git push origin $1
