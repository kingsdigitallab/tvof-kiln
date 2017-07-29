#!/bin/bash
# Call this after updating the content to force TOMCAT to reload source files
touch webapps/ROOT/content/xml/tei/texts/* webapps/ROOT/stylesheets/tei/* webapps/ROOT/content/xml/tei/alists/*
