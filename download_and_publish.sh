#!/bin/bash
# Download latest TEI files, prepare, upload to kiln & reload kiln and django
# Optional argument: jetty port
pushd preprocess && python3 download/download.py dl && cd prepare && bash prepare_and_publish.sh $1 && popd
