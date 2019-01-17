#!/bin/bash
# Call this after updating the content to force Kiln to reload source files
# Optional argument: jetty port
echo "Touch files to force a reload by App server"
touch webapps/ROOT/content/xml/tei/texts/* webapps/ROOT/stylesheets/tei/* webapps/ROOT/content/xml/tei/alists/*
KILN_PORT="$1"
if [ -n "$KILN_PORT" ]; then
    echo "Request Royal to force Kiln to apply HTML conversion and cache it"
    wget -O/dev/null -q http://127.0.0.1:$KILN_PORT/backend/texts/Royal/critical/
    echo "Request Fr20125 to force Kiln to apply HTML conversion and cache it"
    wget -O/dev/null -q http://127.0.0.1:$KILN_PORT/backend/texts/Fr20125/critical/
fi
echo "done"
