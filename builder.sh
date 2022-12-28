#!/bin/bash

RED='\033[1;31m'
YELLOW='\033[1;33m'
GREEN='\033[1;32m'
NC='\033[0m' # No Color

DIR=$(cd `dirname $0` && pwd)
DIR_VUE="${DIR}/modules/AdminPanelWebclient/vue"

TASK="list"

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

getThemeList () 
{
	LIST=$(find ${DIR}/modules/CoreWebclient/styles/themes -maxdepth 1 -mindepth 1 -type d -printf '%f,')
	echo ${LIST::-1}
}

if [ "$TASK" = "list" ]; then
	printf "The script can be used to intall NPM dependencies and build required static files. See the full list of the supported commands:
  - npm
  - build
    - build-main
    - build-admin
  - watch-js
  - watch-styles
  - pack
  - upload
  - prepare-demo
  - upload-demo
  - build-documentation
  - analyze
"
fi

echo TASK: "$TASK"

if [ "$TASK" = "npm" ]; then
	cd ${DIR}
	
	npm install -g gulp-cli
	npm install

	if [ -d "$DIR_VUE" ]; then
		cd ${DIR_VUE}
		npm install
		npm install -g @quasar/cli
	fi
fi

if [ "$TASK" = "build" ]; then
	./builder.sh -t build-main
	./builder.sh -t build-admin
fi

if [ "$TASK" = "build-main" ]; then
	cd ${DIR}
	THEME_LIST="$(getThemeList)"
	gulp styles --themes ${THEME_LIST} --build a
	gulp js:build --build a
	gulp js:min --build a
	#gulp test
fi

if [ "$TASK" = "build-admin" ]; then
	if [ -d "$DIR_VUE" ]; then
		cd ${DIR_VUE}
		npm run build-production
	fi
fi

if [ "$TASK" = "watch-js" ]; then
	cd ${DIR}
	printf "${GREEN}Running watcher for ${RED}JS files\n"$NC
	gulp js:watch
fi

if [ "$TASK" = "watch-styles" ]; then
	cd ${DIR}
	THEME_LIST="$(getThemeList)"
	printf "${GREEN}Running watcher for themes: ${RED}${THEME_LIST}\n"$NC
	gulp styles:watch --themes ${THEME_LIST}
fi

if [ "$TASK" = "pack" ]; then
	echo 'deny from all' > data/.htaccess
	
	PRODUCT_VERSION=`cat VERSION`
	
	if [ -f "$DEMO_MODULES_FILE" ]; then
		PRODUCT_VERSION=`cat VERSION`
		rm ${PRODUCT_NAME}_${PRODUCT_VERSION}.zip
	fi
	
	printf $GREEN"CREATING ZIP FILE: ${RED}${PRODUCT_NAME}_${PRODUCT_VERSION}.zip\n"$NC
	
	zip -rq ${PRODUCT_NAME}_${PRODUCT_VERSION}.zip data/settings/config.json data/settings/modules data/.htaccess modules static system vendor dev adminpanel ".htaccess" dav.php index.php LICENSE VERSION README.md CHANGELOG.txt favicon.ico robots.txt package.json composer.json composer.lock gulpfile.js pre-config.json -x **/*.bak *.git* *node_modules/\*
fi

if [ "$TASK" = "upload" ]; then
	cd ${DIR}
	
	PRODUCT_VERSION=`cat VERSION`
	
	echo UPLOAD ZIP FILE: "${PRODUCT_NAME}_${PRODUCT_VERSION}.zip"
	
	curl -v --ftp-create-dirs --retry 6 -T ${PRODUCT_NAME}_${PRODUCT_VERSION}.zip -u ${FTP_USER}:${FTP_PASSWORD} ftp://afterlogic.com/
fi

if [ "$TASK" = "prepare-demo" ]; then
	cd ${DIR}
	
	printf "Adding extra modules at ${GREEN}${DIR}${NC}...\n"
	
	curl -o ${DIR}/extra_modules.txt -u ${FTP_USER}:${FTP_PASSWORD} ftp://afterlogic.com/demo/${PRODUCT_NAME}/extra_modules.txt
	# wget --no-parent --recursive --level=1 --no-directories --user=${FTP_USER} --password=${FTP_PASSWORD} ftp://afterlogic.com/demo/${PRODUCT_NAME}/

	DEMO_MODULES_FILE="./extra_modules.txt"

	if [ -f "$DEMO_MODULES_FILE" ]; then
		printf $GREEN"Installing demo modules.\n"$NC

		HAS_DEMO=`cat composer.json | grep -o --max-count=1 demo-mode-plugin`

		if [ "${HAS_DEMO}" = "" ]; then
			sed -i '/"require": {/r extra_modules.txt' composer.json
		fi
		
		php composer.phar update afterlogic/aurora-module-demo-mode-plugin
	else
		printf $RED"No extra_modules.txt file is found. Skipping this step.\n"$NC
	fi
	
	printf $GREEN"End 'prepare-demo' task\n"$NC
fi

if [ "$TASK" = "upload-demo" ]; then
	cd ${DIR}
	
	PRODUCT_VERSION=`cat VERSION`
	
	echo UPLOAD ZIP FILE: "${PRODUCT_NAME}_${PRODUCT_VERSION}.zip"
	
	curl -v --ftp-create-dirs --retry 6 -T ${PRODUCT_NAME}_${PRODUCT_VERSION}.zip -u ${FTP_USER}:${FTP_PASSWORD} ftp://afterlogic.com/demo/
fi

if [ "$TASK" = "build-documentation" ]; then
	cd ${DIR}

	PRODUCT_VERSION=`cat VERSION`
	DOCUMENTATION_FILE=${PRODUCT_NAME}_${PRODUCT_VERSION}_phpdocs.zip

	printf "${GREEN}BUILDING DOCUMENTATION\n"$NC

	cd ${DIR}/dev/docs
	# ./build-apigen.sh
	./build-phpdoc.sh
	
	printf "${GREEN}PACKING DOCUMENTATION: ${RED}${DOCUMENTATION_FILE}\n"$NC
	cd ${DIR}/docs/api
	echo $(cd `dirname $0` && pwd)
	zip -rq ${DOCUMENTATION_FILE} *

	curl -v --ftp-create-dirs --retry 6 -T ${DOCUMENTATION_FILE} -u ${FTP_USER}:${FTP_PASSWORD} ftp://afterlogic.com/
fi

if [ "$TASK" = "analyze" ]; then
	cd ${DIR}

	vendor/bin/phpstan analyse | grep '[ERROR]' -F
	
	# if [ $? != 0 ]
    # then
        printf "\r\n To get more details on the found errors please run:\r\n "$YELLOW"vendor/bin/phpstan analyze"$NC"\r\n"
        exit 1
    # fi
fi
