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

# status
STATUS_AHEAD="AHEAD"
STATUS_BEHIND="BEHIND"
STATUS_DIVERGED="DIVERGED"
STATUS_NO_CHANGES="NO CHANGES"
STATUS_UNKNOWN="UNKNOWN"
STATUS_UP_TO_DATE="UP TO DATE"

# status indicators
INDICATOR_AHEAD="Your branch is ahead of"
INDICATOR_BEHIND="Your branch is behind"
INDICATOR_DIVERGED="have diverged"
INDICATOR_NO_CHANGES="nothing to commit, working tree clean"
INDICATOR_UP_TO_DATE="Your branch is up-to-date"

# colors
red=$'\e[1;31m'
grn=$'\e[1;32m'
yel=$'\e[1;33m'
blu=$'\e[1;34m'
gry=$'\e[0;37m'
end=$'\e[0m'

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
    loadRepoList
    if [ ${#repos[@]} -ge 1 ]; then
        fetchRepos
    else
        showNoReposMessage
    fi

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
    echo "Fetching..."
    echo "================================================================================"
    printf "%25.25s|\t%30.30s|\t%s\n" "REPO" "CURRENT BRANCH" "STATUS"
    echo "================================================================================"
	for repo in "${repos[@]}"; do
        (
            cd $repo;
            currentBranch=$(git rev-parse --abbrev-ref HEAD)
            repoName=$(basename `git rev-parse --show-toplevel`)
            git fetch >& /dev/null
            branchStatus=$(git status)
            getStatus
            printf "%25.25s|\t%30.30s|\t%s$status${end}\n" $repoName $currentBranch $statusColor
        ) &
	done
	wait
}

function getStatus {
    if grep -q "$INDICATOR_AHEAD" <<< $branchStatus; then
        status=$STATUS_AHEAD;
        statusColor=${grn}
    elif grep -q "$INDICATOR_UP_TO_DATE" <<< $branchStatus; then
        status=$STATUS_UP_TO_DATE;
        statusColor=${gry}
    elif grep -q "$INDICATOR_NO_CHANGES" <<< $branchStatus; then
        status=$STATUS_NO_CHANGES;
        statusColor=${gry}
    elif grep -q "$INDICATOR_BEHIND" <<< $branchStatus; then
        status=$STATUS_BEHIND;
        statusColor=${red}
    elif grep -q "$INDICATOR_DIVERGED" <<< $branchStatus; then
        status=$STATUS_DIVERGED;
        statusColor=${red}
    else
        status=$STATUS_UNKNOWN
        statusColor=${yel}
    fi
}

function listRepos {
    loadRepoList
    if [ ${#repos[@]} -eq 0 ]; then
        showNoReposMessage
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

function showNoReposMessage {
    printf "You have no repos added.\nAdd one now by running this in your repo's directory:\n\n"
    printf "\t$COMMAND_MAIN $COMMAND_ADD"
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

