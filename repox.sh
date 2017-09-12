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
COMMAND_RESET="reset"
COMMAND_VIEW_STATUS="view"

# others
SEPARATOR="\n"
ICON_ERROR="✗"
ICON_SUCCESS="✓"
ICON_WARN="⚠"

#==================================================
# FUNCTIONS
#==================================================
function init {
	if [ ! -d "$REPOX_DIR" ]; then
		mkdir $REPOX_DIR
		echo "$ICON_SUCCESS Repox directory created."
	fi

	if [ ! -f "$PROFILE_FILE" ]; then
		touch $PROFILE_FILE
		echo "$ICON_SUCCESS $(basename $PROFILE_FILE) file created."
	fi
}

function register {
	if ! git status >& /dev/null; then
  		echo "$ICON_ERROR This folder is not part of a repo."
  		exitValue=1
  		return 1
	fi

	rootDir="$(git rev-parse --show-toplevel)"

	if grep -q $rootDir $PROFILE_FILE; then
        echo "$ICON_WARN This repo directory has already been added."
    else
        echo "$ICON_SUCCESS Successfully added repo directory:"
        printf "(+) "
        (printf "$rootDir$SEPARATOR" | tee -a $PROFILE_FILE)
	fi
}

function viewStatus {
	fetchRepos
}

function showUsage {
	printf "\nUsage: $COMMAND_MAIN {$COMMAND_ADD|$COMMAND_LIST|$COMMAND_RESET|$COMMAND_VIEW_STATUS}\n"
	echo "Commands:"
	printf "\t$COMMAND_ADD\tMonitor current folder's parent repository for status and updates\n"
	printf "\t$COMMAND_LIST\tList all repo directories being monitored\n"
	printf "\t$COMMAND_RESET\tRemove all repo directories from monitoring\n"
	printf "\t$COMMAND_VIEW_STATUS\tView status of monitored repositories\n"
}

function fetchRepos {
    loadRepoList
    echo "Fetching..."
    echo "=========================================================================================================="
    printf "%25.25s|\t%30.30s|\t%s\n" "REPO" "BRANCH NAME" "STATUS"
    echo "=========================================================================================================="
	for repo in "${repos[@]}"; do
        (
            cd $repo;
            currentBranch=$(git rev-parse --abbrev-ref HEAD)
            repoName=$(basename `git rev-parse --show-toplevel`)
            result=$(git fetch >& /dev/null);
            branch_result=$(git status)
            if grep -q "Your branch is ahead of" <<< $branch_result; then
                status="AHEAD";
            elif grep -q "Your branch is up-to-date" <<< $branch_result; then
                status="UP TO DATE";
            elif grep -q "nothing to commit, working tree clean" <<< $branch_result; then
                status="NO CHANGES";
            elif grep -q "Your branch is behind" <<< $branch_result; then
                status="BEHIND";
            elif grep -q "have diverged" <<< $branch_result; then
                status="DIVERGED";
            else
                status="UNKNOWN"
            fi
            printf "%25.25s|\t%30.30s|\t$status\n" $repoName $currentBranch
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

function reset {
    rm -rf $REPOX_DIR
    echo "$ICON_SUCCESS Removed all repo dirs from monitoring."
}

#==================================================
# MAIN ENTRY
#==================================================


if [ "$1" != "$COMMAND_RESET" ]; then
    init
fi

case $1 in
	$COMMAND_ADD )
		register ;;
	$COMMAND_VIEW_STATUS )
		viewStatus ;;
    $COMMAND_LIST )
        listRepos ;;
    $COMMAND_RESET )
        reset ;;
	* )
		echo "$ICON_ERROR: Unknown command or no command supplied."
		showUsage
		exitValue=1 ;;
esac

exit $exitValue

