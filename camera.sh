#!/bin/bash
#
#

# Check if fsweb is installed on ArchLinux
FSWEB=$(pacman -Q | grep fswebcam)
if [ -z "FSWEB" ]; then
	echo "Please install fswebcam"
	curl https://aur.archlinux.org/cgit/aur.git/snapshot/fswebcam.tar.gz -O $DIR
        tar -xvf $DIR/fswebcam.tar.gz
	cd $DIR/fswebcam
 	makepkg -A -i	
fi	

RES='1024x768'
DIR="/home/alarm/KilnCam"

# Replace these with values
SFTFPASS=""
SFTPUSER=""
SFTPPORT=""
SFTPFOLDER=""
SFTPURL=""

MAX_IMAGES=5

echo "------------------------"
echo "Running Camera Utility" 

IMAGE="$(date +"%Y-%m-%d_%H:%M").jpg"
# Uncomment line below to create logs
# fswebcam -r $RES $DIR/images/$IMAGE --log $DIR/fswebcam.log
# Swap line below with line above
fswebcam -r $RES $DIR/images/$IMAGE

echo "------------------------"
echo "Uploading to FTP"

sshpass -p $SFTPPASS sftp -oPort=$SFTPPORT $SFTPUSER@$SFTPURL:$SFTPFOLDER << DELIM
	rm *
	put -r $DIR/images/*
	quit
DELIM

# Swap the deck. Keep $MAX_IMAGES most recent images,  

echo "------------------------"
echo "Cleaning directory"

# Switch from where-ever we may be into the project directory
echo "Switching from $pwd"
cd $DIR	
echo "Now in $pwd"

# Make sure the images folder exists
if [ -d "images" ]; then
	cd images
	IMAGE_COUNT_BEFORE=$(ls -lt | wc -l)
	echo "Found $IMAGE_COUNT_BEFORE images. Max of $MAX_IMAGES."
	
	if [ $IMAGE_COUNT_BEFORE -gt $MAX_IMAGES ]; then
		echo "Deleting excess images."
		ls -tp | tail -n +$MAX_IMAGES | xargs -d '\n' -r rm --
		IMAGE_COUNT_AFTER=$(ls -lt | wc -l)
		IMAGES_DELETED=$[IMAGE_COUNT_BEFORE - IMAGE_COUNT_AFTER]
		echo "Deleted $IMAGES_DELETED images"
	fi
fi
