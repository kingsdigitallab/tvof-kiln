#!/bin/bash
# Call this after updating the content to force TOMCAT to reload source files
echo "Touch files to force a reload by Tomcat"
touch webapps/ROOT/content/xml/tei/texts/* webapps/ROOT/stylesheets/tei/* webapps/ROOT/content/xml/tei/alists/*
TOMCAT_PORT="$1"
if [ -n "$TOMCAT_PORT" ]; then
    echo "Request Royal to force Tomcat to apply HTML conversion and cache it"
    wget -O/dev/null -q http://127.0.0.1:$TOMCAT_PORT/backend/texts/Royal/critical/
    echo "Request Fr20125 to force Tomcat to apply HTML conversion and cache it"
    wget -O/dev/null -q http://127.0.0.1:$TOMCAT_PORT/backend/texts/Fr20125/critical/
fi
echo "done"
