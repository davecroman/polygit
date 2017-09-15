#!/usr/bin/env bash

SCRIPT_FILE="repox.sh"
TARGET_LOCATION="/usr/local/bin/repox"

echo "Installing..."

read -p "This will copy ${SCRIPT_FILE} to ${TARGET_LOCATION}. Press [ENTER] to continue..."
cp $SCRIPT_FILE $TARGET_LOCATION


if cp -rv $SCRIPT_FILE $TARGET_LOCATION; then
    printf "\n\tsuccess: file copied\n\n"
else
    printf "\n\terror: failed to copy file\n\n"
    exit 1;
fi

result=$(which repox)

if [ "$result" = "$TARGET_LOCATION" ]; then
    echo "Successfully installed. You can start using repox now";
else
    echo "warning: $TARGET_LOCATION is not yet in your PATH"
fi