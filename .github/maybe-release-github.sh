#!/bin/bash
set -ev
echo "branch: $GITHUB_REF_NAME"
echo "pull request: $GITHUB_REF_PROTECTED"
echo "repository: $GITHUB_REPOSITORY"
if [ "$GITHUB_REF_NAME" == "make-vertx-redisques-build-pass-on-github-actions" ] && [ "$GITHUB_REF_PROTECTED" == "false" ] && [ "$GITHUB_REPOSITORY" == "gedestroy/vertx-redisques" ]
then
    git reset --hard
    git clean -fd
#    echo 'before Master checked out'
#    git checkout master
#    echo 'Master checked out'
    groovy staging.groovy drop
    echo 'after groovy drop'
    rc=$?
    if [ $rc -ne 0 ]
    then
      echo 'problem when trying to drop, ignored'
    fi
     echo 'starting a new nexus repository ...'
     OUTPUT=$(groovy staging.groovy start)
     echo "repository Id: $OUTPUT"
     mvn -B -Prelease -PpublicRepos jgitflow:release-start jgitflow:release-finish --settings settings.xml -DrepositoryId=${OUTPUT}
    rc=$?
    if [ $rc -eq 0 ]
    then
        groovy staging.groovy close ${OUTPUT}
        groovy staging.groovy promote ${OUTPUT}
        rc=$?
        if [ $rc -ne 0 ]
        then
          echo 'Release failed, cannot promote stage'
          exit rc
        fi
        echo 'Release done, will push'
        git tag
        git push --tags
        git checkout develop
        git push origin develop
      exit 0
    fi
    echo 'Release failed'
    exit rc
else
    echo 'Release skipped'
    exit 0
fi