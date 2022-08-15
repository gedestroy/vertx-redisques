#!/bin/sh
git config --global user.email "swisspush@post.ch"
git config --global user.name "Github-CI"

git config credential.helper "store --file=.git/credentials"
echo "https://${GH_TOKEN}:@github.com" > .git/credentials

chmod +x .github/maybe-release-github.sh