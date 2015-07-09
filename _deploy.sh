#!/bin/bash
# http://www.savjee.be/2014/03/Jekyll-to-S3-deploy-script-with-gzip/
##
# Configuration options
##
CZ_BUCKET='s3://www.adamh.cz/'
EN_BUCKET='s3://www.adamheinrich.com/'
SITE_DIR='_site/'

##
# Usage
##
usage() {
cat << _EOF_
Usage: ${0} [cz | en | all]
    
    cz		Deploy to the cz (adamh.cz) bucket
    en		Deploy to the en (adamheinrich.com) bucket
    all     Deploy to the en then cz bucket
_EOF_
}
 
##
# Color stuff
##
NORMAL=$(tput sgr0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2; tput bold)
YELLOW=$(tput setaf 3)

function red() {
    echo "$RED$*$NORMAL"
}

function green() {
    echo "$GREEN$*$NORMAL"
}

function yellow() {
    echo "$YELLOW$*$NORMAL"
}

##
# Actual script
##

# Expecting at least 1 parameter
if [[ "$#" -ne "1" ]]; then
    echo "Expected 1 argument, got $#" >&2
    usage
    exit 2
fi

if [[ "$1" = "en" ]]; then
	BUCKET=$EN_BUCKET
	green 'Deploying to en bucket'
elif [[ "$1" = "cz" ]]; then
	BUCKET=$CZ_BUCKET
	green 'Deploying to cz bucket'
else
    green 'Running en then cz'
    ./$0 en
    ./$0 cz
    exit 0
fi


red '--> Running Jekyll'
Jekyll build

red '--> Removing unused files'

rm -rf "$SITE_DIR/README.md"
rm -rf "$SITE_DIR/LICENSE.md"

if [[ "$1" = "en" ]]; then
    rm -rf "$SITE_DIR/kontakt"
    rm -rf "$SITE_DIR/fakturacni-udaje"
    rm -rf "$SITE_DIR/index_cz.html"
    rm -rf "$SITE_DIR/404_cz.html"
else
    rm -rf "$SITE_DIR/contact"
    rm -rf "$SITE_DIR/blog"
    rm -rf "$SITE_DIR/public/img"
    mv "$SITE_DIR/index_cz.html" "$SITE_DIR/index.html"
    mv "$SITE_DIR/404_cz.html" "$SITE_DIR/404.html"
fi


red '--> Gzipping all html, css and js files'
find $SITE_DIR \( -iname '*.html' -o -iname '*.css' -o -iname '*.js' \) -exec gzip -9 -n {} \; -exec mv {}.gz {} \;


yellow '--> Uploading css files'
s3cmd sync --exclude '*.*' --include '*.css' --add-header='Content-Type: text/css' --add-header='Cache-Control: max-age=604800' --add-header='Content-Encoding: gzip' $SITE_DIR $BUCKET


yellow '--> Uploading js files'
s3cmd sync --exclude '*.*' --include '*.js' --add-header='Content-Type: application/javascript' --add-header='Cache-Control: max-age=604800' --add-header='Content-Encoding: gzip' $SITE_DIR $BUCKET

# Sync media files first (Cache: expire in 10weeks)
yellow '--> Uploading images (jpg, png, ico)'
s3cmd sync --exclude '*.*' --include '*.png' --include '*.jpg' --include '*.ico' --add-header='Expires: Sat, 20 Nov 2020 18:46:39 GMT' --add-header='Cache-Control: max-age=6048000' $SITE_DIR $BUCKET


# Sync html files (Cache: 2 hours)
yellow '--> Uploading html files'
s3cmd sync --exclude '*.*' --include '*.html' --add-header='Content-Type: text/html' --add-header='Cache-Control: max-age=7200, must-revalidate' --add-header='Content-Encoding: gzip' $SITE_DIR $BUCKET


# Sync everything else
yellow '--> Syncing everything else'
s3cmd sync --delete-removed $SITE_DIR $BUCKET

