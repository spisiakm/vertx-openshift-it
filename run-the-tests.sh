#!/usr/bin/env bash
for i in $(git diff --name-only $TRAVIS_COMMIT_RANGE | grep -oP "^.*?/" | uniq)
do
  mvn clean verify -Popenshift -Dinternal -f "$i"pom.xml
done
