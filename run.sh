#!/bin/bash

# the path to where this file is
# replace this with absolute path if needed
ROOT=$(dirname $0)
cd $ROOT
ROOT=$(pwd)

# directory configuration
BUILD_PATH="${WORKSPACE:=$(readlink -f $(dirname $0))/builds}"

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
	echo "$(basename $0) [-p target_file_prefix] [-f src_folder] {-s smalltalk_script}"
}

# parse options
while getopts ":p:r:s:?" OPT ; do
	case "$OPT" in
    	p)	# prefix
			PROJECT_PREFIX=$OPTARG
			;;
		f) 	# src
			SRC_PATH=$OPTARG
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
	SCRIPTS=("$SCRIPTS_PATH/import-mse.st" "$SCRIPTS_PATH/save-and-quit-image.st")
fi

INFUSION="$ROOT/inFusion"

DATE=`date +%Y-%m-%d--%H-%M-%S`
MSE_FILE="$PROJECT_PREFIX-$DATE.mse"

echo -e "\n"=====STARTING AUTO MOOSE====="\n"
echo -e "\n"Start inFusion"\n"

cd $INFUSION
"./java2mse.sh" $SRC_PATH "famix30" $MSE_FILE

if [ ! -f $MSE_FILE ] ; then
	echo -e "\n"=====ERROR PRODUCING MSE FILE====="\n"Make sure the path to the sources is correct
	exit 1
fi

echo -e "\n"Load in Moose"\n"

COMPLETE_SCRIPT="$SCRIPTS_PATH/to-run.st"

echo "\"this is the complete script to be run\"" > "$COMPLETE_SCRIPT"
echo "wantedMse := '${MSE_FILE}'." >> $COMPLETE_SCRIPT
for FILE in "${SCRIPTS[@]}" ; do
 cat "$FILE" >> "$COMPLETE_SCRIPT"
 echo "!" >> "$COMPLETE_SCRIPT"
done

MOOSE_FILE="moose-$PROJECT_PREFIX-$DATE"
MOOSE_IMAGE_FILE="$MOOSE_FILE.image"
MOOSE_CHANGES_FILE="$MOOSE_FILE.changes"

mkdir "$BUILD_PATH/$MOOSE_FILE"
mv $MSE_FILE "$BUILD_PATH/$MOOSE_FILE"
cd "$BUILD_PATH/$MOOSE_FILE"

cp "$ROOT/res/moose.image" $MOOSE_IMAGE_FILE
cp "$ROOT/res/moose.changes" $MOOSE_CHANGES_FILE
ln -fs "$ROOT/res/PharoV10.sources" "$BUILD_PATH/$MOOSE_FILE"
ln -fs "$ROOT/res/Fonts" "$BUILD_PATH/$MOOSE_FILE"

"$PHARO_VM" $PHARO_PARAM $MOOSE_IMAGE_FILE $COMPLETE_SCRIPT

# cleaning
rm $COMPLETE_SCRIPT
cd $BUILD_PATH
tar -czf "$MOOSE_FILE.tgz" "$MOOSE_FILE"
rm -rf "$BUILD_PATH/$MOOSE_FILE"

echo -e "\n"=====DONE=====

exit 0