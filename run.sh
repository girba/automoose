#!/bin/bash

# the path to where this file is
# replace this with absolute path if needed
ROOT=$(dirname $0)
cd $ROOT
ROOT=$(pwd)

# directory configuration
BUILD_PATH="${WORKSPACE:="$ROOT/builds"}"

# the Pharo virtual machine for running the Moose image
# specify the VM for your platform
PHARO_VM="$ROOT/pharo/Squeak-3.11.3.2135-solaris2.10_i386/bin/squeak"
PHARO_VM="$ROOT/pharo/pharo-vm-0.15.2f-linux/squeak"
PHARO_VM="$ROOT/pharo/Squeak 4.2.2beta1U.app/Contents/MacOS/Squeak VM Opt"

#PHARO_PARAM="-nodisplay -nosound" #for Linux
PHARO_PARAM="-headless" #for Mac

# the location of sources
# copy / link sources in the src folder or change the variable
SRC_PATH="$ROOT/src"

# the desired prefix for the generated files 
# this must correspond to the name specified in the importing script
PROJECT_PREFIX="system"

SCRIPTS_PATH="$ROOT/scripts"

# help function
function display_help() {
	echo "$(basename $0) [-p target_file_prefix] {-s smalltalk_script}"
}

# parse options
while getopts ":p:r:s:?" OPT ; do
	case "$OPT" in
    	p)	# prefix
			PROJECT_PREFIX=$OPTARG
			;;
		s)	# script
			if [ -f "$SCRIPTS_PATH/$OPTARG.st" ] ; then
                SCRIPTS=("${SCRIPTS[@]}" "$SCRIPTS_PATH/$OPTARG.st")
			else
				echo "$(basename $0): invalid script ($OPTARG)"
				exit 1
			fi
			;;
		\?) # show help
			display_help
			exit 1
			;;
	esac
done

if [ -z "$SCRIPTS" ] ; then
	# the default scripts
	SCRIPTS=("$SCRIPTS_PATH/open-moose-panel.st" "$SCRIPTS_PATH/save-and-quit-image.st")
fi

INFUSION="$ROOT/inFusion"

DATE=`date +%Y-%m-%d--%H-%M-%S`
MSE_FILE="$PROJECT_PREFIX-$DATE.mse"

echo -e "\n"=====STARTING AUTO MOOSE====="\n"

COMPLETE_SCRIPT="$SCRIPTS_PATH/to-run.st"

echo "\"this is the complete script to be run\"" > "$COMPLETE_SCRIPT"
echo "wantedMse := '${MSE_FILE}'." >> $COMPLETE_SCRIPT
for FILE in "${SCRIPTS[@]}" ; do
 cat "$FILE" >> "$COMPLETE_SCRIPT"
 echo "!" >> "$COMPLETE_SCRIPT"
done

#copy moose images
MOOSE_FILE="moose-$PROJECT_PREFIX-$DATE"
MOOSE_IMAGE_FILE="$MOOSE_FILE.image"
MOOSE_CHANGES_FILE="$MOOSE_FILE.changes"

mkdir "$BUILD_PATH/$MOOSE_FILE"
cd "$BUILD_PATH/$MOOSE_FILE"

cp "$ROOT/res/moose.image" $MOOSE_IMAGE_FILE
cp "$ROOT/res/moose.changes" $MOOSE_CHANGES_FILE
ln -fs "$ROOT/res/PharoV10.sources" "$BUILD_PATH/$MOOSE_FILE"

cd "$BUILD_PATH/$MOOSE_FILE"

"$PHARO_VM" $PHARO_PARAM $MOOSE_IMAGE_FILE $COMPLETE_SCRIPT

# cleaning
rm $COMPLETE_SCRIPT
cd $BUILD_PATH

#"$ROOT/resize-window.sh" "$BUILD_PATH/$MOOSE_FILE/$MOOSE_IMAGE_FILE"

tar -czf "$MOOSE_FILE.tgz" "$MOOSE_FILE"
rm -rf "$BUILD_PATH/$MOOSE_FILE"

echo -e "\n"=====DONE=====

exit 0