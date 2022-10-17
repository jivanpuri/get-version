#! bin/bash

#get-version.sh
#Use: get-version {branch}
#Output: {new-version}
#Provides automated versioning of your commits using git tags each time your CI/CD workflow runs.
#If no tags preset it will return the version as 1.0.0

MASTER_BRANCH="$1";

outLog() {
	echo "$1"
} >&2

getLatestRevision() {
	outLog "Getting latest tagged revision...";
	if [ "$(git describe --abbrev=0 --tags | wc -l)" -eq "0" ]; then
    outLog ":No tags exists. Setting version to 1.0.0";
		echo "1.0.0"
	else
	  echo "$(git describe --abbrev=0 --tags)"
  fi
}

getRevisionType() {
  local MESSAGE="$(git show -s --format=%s HEAD)";
  outLog "Getting revision type from commit message (major, minor)";
	outLog "Commit message: $MESSAGE";

	if [[ "$MESSAGE" == *"#major"* ]]; then
		echo "major"
	elif [[ "$MESSAGE" == *"#minor"* ]]; then
		echo "minor"
	else
		echo "patch"
	fi
}

split() { IFS="$1" read -r -a return_arr <<< "$2"; }

join() { local IFS="$1"; shift; echo "$*"; }

getNewRevision() {
  OLD_VERSION=$1
  REVISION_TYPE=$2
  BRANCH=$3
  MASTER_BRANCH=$4
	outLog "Getting new revision from revision type and the old version $OLD_VERSION";
	outLog "Revision Type: $REVISION_TYPE";

	split '.' $OLD_VERSION;

	major_revision=${return_arr[0]};
	minor_revision=${return_arr[1]};
	build_number=${return_arr[2]};

	case $REVISION_TYPE in
		major)
			((major_revision++));
			minor_revision=0;
			build_number=0
			;;
		minor)
			((minor_revision++));
			build_number=0
			;;
		patch)
			((build_number++))
			;;
		esac
  if [ $BRANCH = "$MASTER_BRANCH" ]; then
	  echo "$(join . $major_revision $minor_revision $build_number)"
	else
	  echo "$(join . $major_revision $minor_revision $build_number-dev)"
	fi
}

tagRelease() {
	local REVISION_TYPE="$1";
	local REVISION="$2";

	local MESSAGE="$REVISION_TYPE $REVISION";

	outLog "Tagging new release ...";
	outLog "Revision Type: $REVISION_TYPE";
	outLog "Revision: $REVISION";
	outLog "Annotated Message: $MESSAGE";

	git tag -a "$REVISION" -m "$MESSAGE";
	git tag -f latest
}

pushToOrigin() {
	outLog "Pushing changes to origin ...";

	git push 2> /dev/null;
	git push origin :latest 2> /dev/null;
	git push --tags 2> /dev/null;

	outLog "Push successful.";
}

outLog "Branch: $MASTER_BRANCH";
BRANCH="$(git branch --show-current)";
outLog "Current branch: $BRANCH";
REVISION="$(getLatestRevision)";
outLog "Latest Revision: $REVISION";

REVISION_TYPE="patch";
REVISION_TYPE="$(getRevisionType)";
outLog "Revision Type: $REVISION_TYPE";
outLog "Generating new Version";
NEW_VERSION="$(getNewRevision $REVISION $REVISION_TYPE $BRANCH $MASTER_BRANCH)";
outLog "New Version: $NEW_VERSION";
tagRelease $REVISION_TYPE $NEW_VERSION;
#pushToOrigin;
echo "version=$NEW_VERSION" >> $GITHUB_OUTPUT
