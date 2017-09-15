# PolyGit

A simple script to track and update multiple Git repositories in parallel using the terminal.

## Installation

1. Clone this repository
2. From the terminal, go to the root directory of this repository
3. Run the install script and follow the prompts

```
./install.sh
```

`sudo` privileges may be required to copy the script into `/usr/local/bin/`. If so, run the install script with sudo.

## Usage

### Add a repository to montitor

```
cd {directory of Git repository}
polygit add
```

You can add as many repositories as you want.

Note: Limits have not yet been explored.

### View list of monitored repositories

```
polygit list
```

### View status of all monitored repositories in their current branches

```
polygit view
```

Sample Output:

```
================================================================================
                     REPO|	                CURRENT BRANCH|	STATUS
================================================================================
               weatherbox|	            feature/support-SI|	UP TO DATE
           blacksmith-jam|	   feature/weapon-enhancements|	AHEAD
            notetaker-ios|	         feature/refactor-code|	UP TO DATE
        notetaker-android|	      feature/add-new-bookmark|	DIVERGED
            credit-report|	       bugfix/validate-account|	BEHIND
```

### Remove all repositories from montiroing

```
polygit reset
```