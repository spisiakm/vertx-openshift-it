#!/usr/bin/env bash
for i in $(git diff --name-only $TRAVIS_COMMIT_RANGE | grep -oP "^.*?/" | uniq)
do
  echo "$i"pom.xml
done
