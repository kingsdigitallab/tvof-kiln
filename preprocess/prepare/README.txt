This folder contains Python scripts to process the TEI documents.

REQUIREMENTS: python 2 & perl (installed by default on most Macs and Linux systems)

How do I run a script?
==========================

A python script is a file with extension .py that can be run from a terminal window.

On a Mac, the general procedure is as follow:

* Open Finder and locate the folder which contains the Python script
* Right-click the folder name to open the context menu
* Select "New Terminal at Folder", a new Terminal window will appear
* In the window, type "python SCRIPTNAME.py INPUTFILE.xml -o OUTPUTFILE.xml", followed by ENTER key.
* wait until the script has ended
* if you see 'done' at the end, the script executed without bug
* otherwise, take a screenshot and send it to me geoffroy.noel@kcl.ac.uk
* if you see 'written OUTPUTFILE.xml' near the end, an output file was correctly written
* type "exit" then ENTER key to leave the terminal
* verify the content of OUTPUTFILE.xml
* please also verify the date and time of OUTPUTFILE.xml to be sure its content has just been (over)written.

In the above, SCRIPTNAME is the name of the python script,
INPUTFILE is your input file name. Note that INPUTFILE can contain a path.
For example "/Users/USERNAME/Desktop/TVOF/tei/Fr20125.xml"

How do I combine multiple TEI files into one?
=================================================

  python aggregate.py Fr20125_part1.xml Fr20125_part2.xml -o Fr20125_aggregated.xml

This command will create a new file Fr20125_aggregated.xml which is the combination of
Fr20125_part1.xml and Fr20125_part2.xml.

You can have any number of input files, for instance

  python aggregate.py Fr20125_part1.xml Fr20125_part2.xml Fr20125_part3.xml -o Fr20125_aggregated.xml

You can also use * as a wildcard for filenames. E.g.

  python aggregate.py Fr20125_part*.xml -o Fr20125_aggregated.xml

this command will use all files which name matches Fr20125_part*.xml,
where the * stands for any character.

Please note that the input files are processed
in the order of the number found in their name. For instance:

  python aggregate.py Fr20125_part2.xml Fr20125_part1.xml -o Fr20125_aggregated.xml

  python aggregate.py Fr20125_part1.xml Fr20125_part2.xml -o Fr20125_aggregated.xml

both commands will place Fr20125_part1.xml before Fr20125_part2.xml,
because the script uses "1" and "2" in the name to determine the order.

It is also possible to specify a range of numbers:

  python aggregate.py Fr*part{1..3}.xml -o Fr20125_aggregated.xml

This is equivalent to:

  python aggregate.py Fr20125_part1.xml Fr20125_part2.xml Fr20125_part3.xml -o Fr20125_aggregated.xml

How do I convert all the shorthands into TEI?
=============================================

Your file may contain shorthands for frequence TEI constructs. To convert them
all in one go:

  python convert.py Fr20125_aggregated.xml -o Fr20125_converted.xml

Can I replace my original file with the converted one?
======================================================

Yes, if you are absolutely sure Fr20125_part_X_converted.xml is correctly converted,
you can, if you want, replace your original Fr20125_part1.xml with the following
file:

Fr20125_part_X_converted.xml.pre.xml

and rename it to Fr20125_part1.xml in your source directory. Please make sure
you have a back up of the file before replacing it.

All shorthands in that file are converted, except for the lowecases in <XName>
elements (i.e. the shorthand ¡).

How do I tokenise the text?
===============================

  python tokenise.py Fr20125_converted.xml -o Fr20125_tokenised.xml

In that example Fr20125_aggregated.xml is your aggregated TEI input file and
Fr20125_tokenised.xml is a newly created file with the same content but all
words marked up with <w> elements.

How do I generate a KWIC xml file?
==================================

  python kwic.py Fr20125_tokenised.xml -o Fr20125_kwic.xml

This will produce a KWIC list xml document from all the tokens found in
Fr20125_tokenised.xml.

How can preview a KWIC?
=======================

Convert the kwic xml file into a html:

  python kwic_html.py Fr20125_kwic.xml -o Fr20125_kwic.html

then open that file in your browser.

How can I do everything in one go ?
=======================================

To run all those scripts in sequence automatically and produce all the intermediate outputs:

  python doall.py Fr20125_part1.xml Fr20125_part2.xml -o prefix

This will produce all the output files described above, all starting with the given prefix.

If you don't need the kwic files, you can use -c:

  python doall.py Fr20125_part1.xml Fr20125_part2.xml -c -o prefix

Can you summarise the steps?
============================

For instance the following command:

$ python2 ../../prepare/doall.py fr20125/{1..2}_Fr_*.xml -o processed/

would run these scripts:

# AGGREGATE
python2 aggregate.py fr20125/1_Fr_20125_Hannah.xml fr20125/2_Fr_20125_Teresa.xml -o processed/aggregated.xml
=> processed/aggregated.xml

# CONVERT
python2 convert.py processed/aggregated.xml -o processed/converted.xml
perl /home/jeff/src/workspace/tvof/tvof-kiln/preprocess/prepare/convert.perl < processed/aggregated.xml > processed/converted.xml.pre.xml
=> processed/converted.xml

# VALIDATE
python2 validate.py processed/converted.xml -o processed/validation.log
=> processed/validation.log

# TOKENISE
python2 tokenise.py processed/converted.xml -o processed/tokenised.xml
=> processed/tokenised.xml

# KWIC XML
python2 kwic.py processed/tokenised.xml -o processed/kwic.xml
=> written processed/kwic.xml

# KWIC HTML
python2 kwic_html.py processed/kwic.xml -o processed/kwic.html
=> processed/kwic.html
