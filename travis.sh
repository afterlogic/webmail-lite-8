#!/bin/bash

TASK="build"
PRODUCT_VERSION=`cat VERSION`

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -t|--task)
    TASK="$2"
    shift # past argument
    shift # past value
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

echo TASK  = "$TASK"

if [ "$TASK" = "build" ]; then
	npm install -g gulp-cli
	npm install ./modules/CoreWebclient

	gulp styles --themes Default,DeepForest,Funny
	gulp js:build
	gulp js:min
	gulp test
	
	echo CREATE ZIP FILE  = "${PRODUCT_NAME}_${PRODUCT_VERSION}.zip"
	
	zip -r ${PRODUCT_NAME}_${PRODUCT_VERSION}.zip data/settings/modules modules static system vendor dev ".htaccess" dav.php index.php LICENSE VERSION README.md favicon.ico robots.txt composer.json modules.json gulpfile.js pre-config.json -x **/*.bak *.git*
	
fi

if [ "$TASK" = "upload" ]; then

	echo UPLOAD ZIP FILE  = "${PRODUCT_NAME}_${PRODUCT_VERSION}.zip"
	
	curl --ftp-create-dirs -T ${PRODUCT_NAME}_${PRODUCT_VERSION}.zip -u ${FTP_USER}:${FTP_PASSWORD} ftp://afterlogic.com/
	
fi

