#!/bin/sh

echo "Make sure you have a pendrive formatted as ext2 and mounted under /media/$SUDO_USER/KEY"
read foo
cd /root/ubuntu-ad/



echo "Generating recovery key"
echo -n > key-ad.txt
for i in 1 2 3 4 5
do
    base64 /dev/urandom | head -c 4 | tr 'a-z' 'A-Z' | tee -a key-ad.txt
    echo -n '-' | tee -a key-ad.txt
done
base64 /dev/urandom | head -c 4 | tr 'a-z' 'A-Z' | tee -a key-ad.txt
echo ""


echo "Generating USB key"
base64 /dev/urandom | head -c 1024 | tee key-usb.txt
echo ""



echo "Adding keys to LUKS store"
read foo
cryptsetup luksAddKey /dev/sda3 key-ad.txt
cryptsetup luksAddKey /dev/sda3 key-usb.txt



echo "Setting up USB key"
read foo
mv key-usb.txt /media/$SUDO_USER/KEY/.keyfile
chown root.root /media/$SUDO_USER/KEY/.keyfile
chmod 0400 /media/$SUDO_USER/KEY/.keyfile



echo "Setting up crypttab"
read foo
sed -i.orig 's@none\s*luks,discard@/dev/disk/by-label/KEY:/.keyfile luks,keyscript=/root/ubuntu-ad/unlock.sh@g' /etc/crypttab



echo "Updating initrd"
read foo
update-initramfs -u



echo "Adding Grub workaround"
read foo
sed -i.orig 's/quiet splash/quiet splash luks=no/g' /etc/default/grub



echo "Updating Grub"
read foo
update-grub
