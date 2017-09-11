#!/bin/bash 

#==================================================
# CONSTANTS
#==================================================

# files and directories
REPOX_DIR=~/.repox
PROFILE_FILE="$REPOX_DIR/profile.conf"

# commands
COMMAND_ADD="add"
COMMAND_MAIN="repox"
COMMAND_LIST="list"
COMMAND_VIEW_STATUS="view"

#==================================================
# FUNCTIONS
#==================================================
function init {
	if [ ! -d "$REPOX_DIR" ]; then
		echo "Creating repox directory"
		mkdir $REPOX_DIR
	fi

	if [ ! -f "$PROFILE_FILE" ]; then
		echo "Creating profile.conf"
		touch $PROFILE_FILE
	fi
}

function register {
	if ! git status >& /dev/null; then
  		echo "error: This folder is not a repo."
  		exitValue=1
  		return 1
	fi

	rootDir="$(git rev-parse --show-toplevel)"

	if grep -q $rootDir $PROFILE_FILE; then
        echo "This repo directory has already been added."
    else
        echo "Successfully added repo directory:"
        printf "(+) "
        (printf "$rootDir" | tee -a $PROFILE_FILE)
	fi
}

function viewStatus {
	fetchRepos
}

function showUsage {
	printf "\nUsage: repos {add|view}\n"
	echo "Commands:"
	printf "\t$COMMAND_ADD\tMonitor current folder's parent repository for status and updates\n"
	printf "\t$COMMAND_VIEW_STATUS\tView status of monitored repositories\n"
}

function fetchRepos {
    loadRepoList
    echo "Fetching..."
	for repo in "${repos[@]}"; do
        (
            cd $repo;
            result=$(git fetch);
            echo "Fetched $repo: $result"
        ) &
	done
	wait
}

function listRepos {
    loadRepoList

    if [ ${#repos[@]} -eq 0 ]; then
        printf "You have no repos added.\nAdd one now by running this in your repo's directory:\n\n"
        printf "\t$COMMAND_MAIN $COMMAND_ADD"
        return
    else
        for repo in "${repos[@]}"; do
            echo "$repo"
	    done
    fi
}

function loadRepoList {
    filelines=`cat $PROFILE_FILE`
    for line in $filelines ; do
        if [ -n "$line" ]; then
            repos+=("$line")
        fi
    done
}

#==================================================
# MAIN ENTRY
#==================================================

exitValue=0

init
case $1 in
	$COMMAND_ADD )
		register ;;
	$COMMAND_VIEW_STATUS )
		viewStatus ;;
    $COMMAND_LIST )
        listRepos ;;
	* )
		echo "error: Unknown command or no command supplied."
		showUsage
		exitValue=1 ;;
esac

exit $exitValue

