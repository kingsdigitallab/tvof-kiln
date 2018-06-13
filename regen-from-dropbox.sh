#!/bin/bash
cd /vol/tvof/webroot/stg/tvof-kiln/KWIC/tokenise/ && bash dropbox2tomcat.sh && cd /vol/tvof/webroot/stg/tvof-kiln && bash force_reload.sh 8181 && touch /vol/tvof/webroot/stg/django/tvof-django/tvof/wsgi.py
