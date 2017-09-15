#!/usr/bin/env bash

PROJECT_NAME="PolyGit"
COMMAND_NAME="polygit"
SCRIPT_FILE="${COMMAND_NAME}.sh"
TARGET_LOCATION="/usr/local/bin/${COMMAND_NAME}"

overwrite=0

# Warn the user if file already exists and ask for confirmation
if [ -f "$TARGET_LOCATION" ]; then
    echo "warning: $TARGET_LOCATION already exists."
    while true; do
        read -p "Would you like to overwrite the file? (y/n): " yn
        case $yn in
            [Yy]* ) overwrite=1; break ;;
            [Nn]* ) exit ;;
            * ) echo "Please answer y/Y or n/N.";;
        esac
    done
fi

# Do not prompt for confirmation if user agreed to overwrite
if (( $overwrite == 0 )); then
    read -p "This will copy ${SCRIPT_FILE} to ${TARGET_LOCATION}. Press [ENTER] to continue..."
fi

echo "Installing..."
if cp -rv $SCRIPT_FILE $TARGET_LOCATION; then
    printf "\n\tsuccess: file copied\n\n"
else
    printf "\n\terror: failed to copy file\n\n"
    exit 1;
fi

result=$(which $COMMAND_NAME)

if [ "$result" = "$TARGET_LOCATION" ]; then
    polygit init
    echo "Successfully installed. You can start using ${COMMAND_NAME} now.";
else
    echo "warning: $TARGET_LOCATION is not yet in your PATH"
fi