# tvof-kiln
Contains the Kiln part of the TVOF resource

Content & purpose:
* preprocessing scripts: download TEI files from dropbox, convert shorthands, combine fragments, ...
* Kiln implementation to convert TEI files to HTML and serve them on request (runs on jetty)
* XSLT templates for the TEI to HTML conversion & the resolution of the mapping between texts based on the alignment files

Files:
* webapps/ROOT/stylesheets/tei/to-html.xsl: custom conversion of html to TEI for TVoF
* webapps/ROOT/sitemaps/main.xmap:

The core material is located in webapps/ROOT/content/xml/tei but it is NOT part of this repository.

* webapps/ROOT/content/xml/tei/alists/TVOF_para_alignment.xml: the full alignment file (TEI)
* webapps/ROOT/content/xml/tei/texts/*.xml: the individual manuscript texts (Royal 20 D, Fr 20125, TEI)

For development and testing purpose, instead of generating those files you can just copy the latest version from webapps/ROOT/content/xml/tei-archived to webapps/ROOT/content/xml/tei

Scripts:
* download_and_publish.sh: download TEI from Dropbox, convert, aggregate, tokenise, and place full TEI files in Kiln content dir, then reload Kiln service and Django app
* build.sh : starts kiln on your local machine (please don't use that on servers, as they have a permanent jetty service running)
* preprocess
..* download/download.py: download from dropbox and unzip into data subdir
..* prepare/prepare_and_publish.sh: aggregate, convert, downloaded files and place results into kiln content dirs
..* prepare/doall.py: aggregate, convert, tokenise, generate Kwic for a single manucript from TEI fragments


