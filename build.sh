#!/bin/bash
npm install -g gulp-cli
npm install ./modules/CoreWebclient

gulp styles --themes Default,DeepForest,Funny
gulp js:build
gulp js:min
gulp test

zip -r package.zip data/settings/modules modules static system vendor  ".htaccess" dav.php common.php index.php LICENSE VERSION README.md favicon.ico robots.txt composer.json modules.json gulpfile.js pre-config.json -x **/*.bak
