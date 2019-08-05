#!/bin/bash
# Generate html files from TEI files.
# Optional argument: jetty port
# Method: start kiln in the background, download html from it, stop kiln
echo "Touch files to discard kiln's cache"
touch webapps/ROOT/content/xml/tei/texts/* webapps/ROOT/stylesheets/tei/* webapps/ROOT/content/xml/tei/alists/*
KILN_PORT="$1"
if [ -z "$KILN_PORT" ]; then
    KILN_PORT="9999"
fi
KILN_URL="http://127.0.0.1:$KILN_PORT"
OUT_PATH="kiln_out"

download_from_kiln() {
    WEB_PATH="$1"
    # generate a slug from the web path
    # same as kiln_requester.py _get_urlid_from_url()
    FILENAME=$(echo "$WEB_PATH" | tr '/[:upper:]' '-[:lower:]' | sed -e 's#[^a-z0-9-]##g' | sed -e 's#^-\|-$##g')
    echo " $KILN_URL/$WEB_PATH => $OUT_PATH/$FILENAME"
    wget -O"$OUT_PATH/$FILENAME" -q $KILN_URL/$WEB_PATH
}

if [ ! -d "$OUT_PATH" ]; then
    echo "ERROR: output folder '$OUT_PATH' not found. Create it under your django project and symlink it here (ln -s)."
    exit
fi

if [ -n "$KILN_PORT" ]; then
    netstat -nl | grep ":$KILN_PORT" > /dev/null && echo "ERROR: kiln is already running on port $KILN_PORT" && exit

    echo "Publication path: $OUT_PATH"
    echo "Start Kiln (port $KILN_PORT)"
    bash build.sh >> build.log 2>&1 &
    KILN_PID=$!
    echo "Kiln process id = $KILN_PID"

    echo "Waiting for Kiln to start..."
    wget --retry-connrefused --waitretry=1 --read-timeout=10 --timeout=10 -t 20 -O /dev/null -o /dev/null -q $KILN_URL
    if [ "$?" -ne "0" ]; then
        echo "ERROR: time out trying to request home page from kiln ($KILN_URL)"
        OK=0
    else
        cp "./preprocess/download/data/bibliography/Select Bibliography.xml" "./webapps/ROOT/content/xml/tei/bibliography.xml"
        download_from_kiln "backend/bibliography/"
        download_from_kiln "backend/texts/Fr20125/semi-diplomatic/"
        download_from_kiln "backend/texts/Fr20125/interpretive/"
        download_from_kiln "backend/texts/Royal/semi-diplomatic/"
        download_from_kiln "backend/texts/Royal/interpretive/"
        download_from_kiln "backend/preprocess/alists/TVOF_para_alignment.xml"
    fi

    echo "Stop Kiln"
    pkill -P $KILN_PID
fi
echo "done"
