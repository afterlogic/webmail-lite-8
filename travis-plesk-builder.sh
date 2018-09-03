#!/bin/bash

# external config variables:
# - PRODUCT_NAME
# - PRODUCT_TITLE
# - PRODUCT_WEBSITE
# - PRODUCT_DOWNLOAD
# - PRODUCT_ZIP_URL
# - FTP_USER
# - FTP_PASSWORD

# dev
# PRODUCT_NAME="webmail-lite"
# PRODUCT_TITLE="Afterlogic WebMail Lite"
# PRODUCT_WEBSITE=https://afterlogic.org/webmail-lite
# PRODUCT_DOWNLOAD=https://afterlogic.org/download/webmail-lite-php
# PRODUCT_ZIP_URL=https://afterlogic.org/download/webmail_php.zip

TASK="build"

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

# echo TASK: "$TASK"

if [ "$TASK" = "build" ]; then
	echo DOWNLOAD PLESK TEMPLATE
		# wget http://github.com/afterlogic/plesk-package-template/archive/latest.zip -nv --no-check-certificate
		wget http://codeload.github.com/afterlogic/plesk-package-template/zip/latest -O plesk-package-template.zip -nv --no-check-certificate
		
	# echo DOWNLOAD PRODUCT
		# wget ${PRODUCT_ZIP_URL} -nv

	echo POPULATE TEMPLATE
		PRODUCT_VERSION=`cat VERSION`
		
		mkdir ./template
		# unzip -q ./plesk-package-template.zip -d ./template
		unzip -q ./plesk-package-template.zip
		cp -r ./plesk-package-template-latest/* ./template

		unzip -q ./${PRODUCT_NAME}_${PRODUCT_VERSION}.zip -d ./template/htdocs
    
	echo POPULATE APP-META.XML
		PRODUCT_RELEASE="1"

		VERDOT=$(echo $PRODUCT_VERSION | grep -o '\.' | wc -l)
		while [ $VERDOT -lt 2 ]
		do 
		PRODUCT_VERNUM=$PRODUCT_VERNUM".0"
			VERDOT=$[$VERDOT+1]
		done
		
		# sed -i "s/%PRODUCT_FULLNAME%/$PRODUCT_FULLNAME/g" ./template/APP-META.xml
		# sed -i "s/%PRODUCT_PACKAGE%/$PRODUCT_PACKAGE/g" ./template/APP-META.xml
		sed -i "s/%PRODUCT_NAME%/${PRODUCT_TITLE}/g" ./template/APP-META.xml
		sed -i "s/%PRODUCT_VERSION%/$PRODUCT_VERNUM/g" ./template/APP-META.xml
		sed -i "s/%PRODUCT_RELEASE%/$PRODUCT_RELEASE/g" ./template/APP-META.xml
		sed -i "s|%PRODUCT_WEBSITE%|${PRODUCT_WEBSITE}|g" ./template/APP-META.xml
		sed -i "s|%PRODUCT_DOWNLOAD%|${PRODUCT_DOWNLOAD}|g" ./template/APP-META.xml
fi

if [ "$TASK" = "xmllog" ]; then
	first_seen=1

	while read line ; do
		line=`echo $line | tr -d '\015'`
		token=`echo "$line" | awk '{print $1}' | sed "s/\[//;s/\]//"`
		[ ${#token} -gt 1 ] && {
		[ $first_seen -gt 0 ] || echo "		</version>"
		first_seen=0
		echo "		<version version=\"$token\" release=\"1\">"
		continue ;
		}
		[ ${#token} -gt 0 ] && {
		line=`echo "$line" | tr -d '<>&'`
		echo "			<entry>${line}</entry>" ;
		}    
	done

	[ $first_seen -gt 0 ] || echo "		</version>"
fi

if [ "$TASK" = "log" ]; then	
	echo GENERATE CHANGELOG
		cat ./CHANGELOG.md | ./travis-plesk-builder.sh -t xmllog > ./changelog.xml
		
		sed -i -e "/%PRODUCT_CHANGELOG%/ {r ./changelog.xml
		d}" ./template/APP-META.xml
	
	echo GENERATE CHANGELOG DONE
fi	
	
if [ "$TASK" = "zip" ]; then
	PRODUCT_VERSION=`cat VERSION`
	
	echo BUILD ARCHIVE
		cd ./template
		zip -rq ../${PRODUCT_NAME}-plesk_${PRODUCT_VERSION}.zip .
		
	echo BUILD ARCHIVE DONE
fi

if [ "$TASK" = "upload" ]; then
	PRODUCT_VERSION=`cat VERSION`

	echo UPLOAD ZIP FILE: "${PRODUCT_NAME}-plesk_${PRODUCT_VERSION}.zip"
	
	curl --ftp-create-dirs -T ${PRODUCT_NAME}-plesk_${PRODUCT_VERSION}.zip -u ${FTP_USER}:${FTP_PASSWORD} ftp://afterlogic.com/
	
	echo UPLOAD DONE
fi
