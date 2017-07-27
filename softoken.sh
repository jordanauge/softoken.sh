#!/bin/bash
#
# Automatize token generation with Softoken-II (KDE flavour)
# by Jordan Augé <jordan.auge@free.fr>
# License: GPLv3
#
# Prerequisite:
#  - A working version of Softoken-II installed through Wine and initialized
#  - Dependencies: wine xvfb kwin qdbus xdotool kwalletmanager xsel
#
# Functionalities:
#  - Stores password in kwallet
#  - Uses a virtual X server in framebuffer to avoid interaction / interruption
#  due to current Desktop activity (useful for scripts)
#  - Copies generated token to stdout and clipboard
#
# TODO:
#  * after upgrade : PIN Return
#  * success : Return
#  * stinit
#

# Name of the application in kwallet
APP="softoken"
# Name of the folder in kwallet
FOLDER="softoken"
# Dummy entry for the password, ideally the username
LOGIN="dummy"

ID=$(qdbus org.kde.kwalletd5 /modules/kwalletd5 org.kde.KWallet.open kdewallet 0 $APP)

if [[ $# == 1 ]]; then
    echo "Updating Softoken password in kwalletmanager..."
    # Create a wallet folder
    qdbus org.kde.kwalletd5 /modules/kwalletd5 createFolder $ID $FOLDER $APP
    # Write an entry for password
    qdbus org.kde.kwalletd5 /modules/kwalletd5 writeEntry $ID $FOLDER $LOGIN test 1 $APP
    # Write the password
    qdbus org.kde.kwalletd5 /modules/kwalletd5 writePassword $ID $FOLDER $LOGIN $1 $APP
    echo "Done."
    exit
fi

# List folders
#qdbus org.kde.kwalletd5 /modules/kwalletd5 folderList $ID $APP
# Get login
#qdbus org.kde.kwalletd5 /modules/kwalletd5 entryList $ID $FOLDER $APP

# Retrieve stored password
PASSWORD=$(qdbus org.kde.kwalletd5 /modules/kwalletd5 readPassword $ID $FOLDER $LOGIN $APP)

if [[ $PASSWORD == "" ]]; then
    echo "E: No password found in kwallet. Run $0 PASSWORD"
    exit 1
fi

Xvfb :1 -shmem -screen 0 1280x1024x24 1>/dev/null 2>/dev/null &
PID_XVFB=$?
export DISPLAY=:1.0

/usr/bin/kwin 1>/dev/null 2>/dev/null &
PID_KWIN=$?

wine ~/.wine/drive_c/Program\ Files/Secure\ Computing/SofToken-II/SofToken-II.exe 1>/dev/null 2>/dev/null &
sleep 2

# Test error
a=`xdotool search --name "Erreur du programme"`
if [[ "$a" ]]; then
  xdotool windowactivate --sync $a
  xdotool key Return
  sleep 0.5
fi

a=`xdotool search --name "SofToken II"`
if [[ "$a" ]]; then
  xdotool windowactivate --sync $a
  xdotool key Return
  sleep 0.5
fi

a=`xdotool search --name "SofToken II Registration"`
if [[ "$a" ]]; then
  xdotool windowactivate --sync $a
  xdotool key alt+U
  xdotool key Return
  sleep 0.5
fi

# Enter PIN code to generate one time password
for (( i=0; i<${#PASSWORD}; i++ )); do
  xdotool key "${PASSWORD:$i:1}"
done
xdotool key Return

a=`xdotool search --name "SofToken II"`
xdotool mousemove --window $a 200 120
xdotool click --repeat 2 1
xdotool key ctrl+C

TOKEN=$(xsel -b --output)

xdotool key Tab
xdotool key Return

echo $TOKEN

kill -9 $PID_KWIN
kill -9 $PID_XVFB
