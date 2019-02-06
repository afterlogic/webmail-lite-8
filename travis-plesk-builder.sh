#!/bin/bash

# external config variables:
# PRODUCT_NAME
# PLESK_PRODUCT_TITLE
# PLESK_PRODUCT_FULLTITLE
# PLESK_PRODUCT_WEBSITE
# PLESK_PRODUCT_DOWNLOAD
# FTP_USER
# FTP_PASSWORD

# dev
# PRODUCT_NAME="webmail-lite"
# PLESK_PRODUCT_TITLE="WebMail Lite"
# PLESK_PRODUCT_FULLTITLE="Afterlogic WebMail Lite 8"
# PLESK_PRODUCT_WEBSITE=https://afterlogic.org/webmail-lite
# PLESK_PRODUCT_DOWNLOAD=https://afterlogic.org/download/webmail-lite-php

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

if [ "$TASK" = "build" ]; then
  echo DOWNLOAD PLESK TEMPLATE
    # wget http://github.com/afterlogic/plesk-package-template/archive/latest.zip -nv --no-check-certificate
    wget http://codeload.github.com/afterlogic/plesk-package-template/zip/latest -O plesk-package-template.zip -nv --no-check-certificate

  echo POPULATE TEMPLATE
    PRODUCT_VERSION=`cat VERSION`

    mkdir ./template
    # unzip -q ./plesk-package-template.zip -d ./template
    unzip -q ./plesk-package-template.zip
    cp -r ./plesk-package-template-latest/* ./template

    unzip -q ./${PRODUCT_NAME}_${PRODUCT_VERSION}.zip -d ./template/htdocs

  echo POPULATE APP-META.XML
    PRODUCT_RELEASE="1"
    PRODUCT_VERSION_TRIMMED=$(echo $PRODUCT_VERSION | grep '^[\d|\.]*' -o -P)

    DOT_COUNT=$(echo $PRODUCT_VERSION_TRIMMED | grep -o '\.' | wc -l)

    while [ $DOT_COUNT -lt 2 ]
    do 
      PRODUCT_VERSION_TRIMMED=$PRODUCT_VERSION_TRIMMED".0"
      DOT_COUNT=$[$DOT_COUNT+1]
    done

    INSTALL_SIZE=$(du -sb ./template/htdocs | cut -f 1)

    sed -i "s/%PRODUCT_FULLNAME%/$PLESK_PRODUCT_FULLTITLE/g" ./template/APP-META.xml
    sed -i "s/%PRODUCT_NAME%/${PLESK_PRODUCT_TITLE}/g" ./template/APP-META.xml
    sed -i "s/%PRODUCT_VERSION%/$PRODUCT_VERSION_TRIMMED/g" ./template/APP-META.xml
    sed -i "s/%PRODUCT_RELEASE%/$PRODUCT_RELEASE/g" ./template/APP-META.xml
    sed -i "s/%INSTALL_SIZE%/$INSTALL_SIZE/g" ./template/APP-META.xml
    sed -i "s|%PRODUCT_WEBSITE%|${PLESK_PRODUCT_WEBSITE}|g" ./template/APP-META.xml
    sed -i "s|%PRODUCT_DOWNLOAD%|${PLESK_PRODUCT_DOWNLOAD}|g" ./template/APP-META.xml
fi

if [ "$TASK" = "xmllog" ]; then
  first_seen=1

  while read line ; do
    line=`echo $line | tr -d '\015'`
    token=`echo "$line" | awk '{print $1}' | sed "s/\[//;s/\]//"`
    [ ${#token} -gt 1 ] && {
    [ $first_seen -gt 0 ] || echo "    </version>"
    first_seen=0
    echo "    <version version=\"$token\" release=\"1\">"
    continue ;
    }
    [ ${#token} -gt 0 ] && {
    line=`echo "$line" | tr -d '<>&'`
    echo "      <entry>${line}</entry>";
    }
  done

  [ $first_seen -gt 0 ] || echo "    </version>"
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

  curl --ftp-create-dirs --retry 6 -T ${PRODUCT_NAME}-plesk_${PRODUCT_VERSION}.zip -u ${FTP_USER}:${FTP_PASSWORD} ftp://afterlogic.com/

  echo UPLOAD DONE
fi
