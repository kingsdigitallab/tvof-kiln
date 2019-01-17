#!/bin/bash
# Download latest TEI files, prepare, upload to kiln & reload kiln and django
# Optional argument: jetty port
WSGI_FILE="tvof-django/tvof/wsgi.py"
if [ -f $WSGI_FILE ]; then
    pushd preprocess && python download/download.py dl && cd prepare && bash prepare_and_publish.sh $1 && popd && touch $WSGI_FILE
else
    echo "$WSGI_FILE not found, please create a symlink to tvof-django"
fi
