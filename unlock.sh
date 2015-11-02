#!/bin/sh

ask_for_password () {
#    cryptkey="Unlocking the disk $cryptsource ($crypttarget)\nEnter passphrase: "
    cryptkey="Unlocking the disk $crypttarget\nEnter passphrase or insert USB key, then press Return: "
    if [ -x /bin/plymouth ] && plymouth --ping; then
        cryptkeyscript="plymouth ask-for-password --prompt"
        cryptkey=$(printf "$cryptkey")
    else
        cryptkeyscript="/lib/cryptsetup/askpass"
    fi
    $cryptkeyscript "$cryptkey"
}

device=$(echo $1 | cut -d: -f1)
filepath=$(echo $1 | cut -d: -f2)

# Ask for password if device doesn't exist
if [ ! -b $device ]; then
    ask_for_password
    exit
fi

mkdir /tmp/auto_unlocker
mount $device /tmp/auto_unlocker

# Again ask for password if device exist but file doesn't exist
if [ ! -e /tmp/auto_unlocker$filepath ]; then
    ask_for_password
else
    cat /tmp/auto_unlocker$filepath
fi

umount /tmp/auto_unlocker
