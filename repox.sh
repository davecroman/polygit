#!/bin/bash 

#==================================================
# CONSTANTS
#==================================================

# files and directories
REPOX_DIR=~/.repox
PROFILE_FILE="$REPOX_DIR/profile.conf"

# commands
COMMAND_ADD="add"
COMMAND_VIEW_STATUS="view"

#==================================================
# FUNCTIONS
#==================================================
function init {
	if [ ! -d "$REPOX_DIR" ]; then
		echo "Creating repox directory"
		mkdir ~/.repox
	fi

	if [ ! -f "$PROFILE_FILE" ]; then
		echo "Creating profile.conf"
		touch profile.conf
	fi
}

function register {
	if ! git status >& /dev/null; then
  		echo "This folder is not a repo"
	fi

	rootDir="$(git rev-parse --show-toplevel)"
	rootDir=$(basename $rootDir)

	(echo $rootDir | tee $PROFILE_FILE)
	echo "Repo successfully registered"
}

function viewStatus {
	echo "Status"
}

function showUsage {
	printf "\nUsage: repos {add|view}\n"
	echo "Commands:"
	printf "\t$COMMAND_ADD\tMonitor current folder's parent repository for status and updates\n"
	printf "\t$COMMAND_VIEW_STATUS\tView status of monitored repositories\n"
}

function fetchRepos {
	repos=$1
	for repo in "${repos[@]}"; do
		(echo $repo; cd $repo; git fetch) &
	done
	wait
}

#==================================================
# MAIN ENTRY
#==================================================

exitValue=0

case $1 in
	$COMMAND_ADD )
		register ;;
	$COMMAND_VIEW_STATUS )
		viewStatus ;;
	* )
		echo "fatal: Unknown command or no command supplied."
		showUsage
		exitValue=1 ;;
esac

printf "\nExiting: $exitValue"
exit $exitValue

