This folder contains Python scripts to process the TEI documents.

Q1. How do I run a script?
==========================

A python script is a file with extension .py that can be run from a terminal window.

On a Mac, the general procedure is as follow:
* Open Finder and locate the folder which contains the Python script
* Right-lick the folder name to open the context menu
* Select "New Terminal at Folder"
* type "python SCRIPTNAME.py INPUTFILE.xml -o OUTPUTFILE.xml", followed by ENTER key. 
* wait until the script has ended
* if you see 'done' at the end, the script executed without bug
* otherwise, take a screenshot and send it to me geoffroy.noel@kcl.ac.uk
* if you see 'written XXX.xml' near the end, an output file was correctly written
* type "exit" then ENTER key to leave the terminal
* verify the content of OUTPUTFILE.xml
* please also verify the date and time of OUTPUTFILE.xml to be sure its content has just been (over)written.

In the above, SCRIPTNAME is the name of the python script, 
INPUTFILE is your input file name. Note that INPUTFILE can contain a path. 
For example "/Users/USERNAME/Desktop/TVOF/tei/Fr20125.xml"

Q2. How do I combine multiple TEI files into one?
=================================================

"python aggregate.py Fr20125_part1.xml Fr20125_part2.xml -o Fr20125_combined.xml"

This command will create a new file Fr20125_combined.xml which is the combination of
Fr20125_part1.xml and Fr20125_part2.xml.

You can have any number of input files, for instance

"python aggregate.py Fr20125_part1.xml Fr20125_part2.xml Fr20125_part3.xml -o Fr20125_combined.xml"

You can also use * as a wildcard for filenames. E.g.
 
"python aggregate.py Fr20125_part*.xml -o Fr20125_combined.xml"

this command will use all files which name matches Fr20125_part*.xml, 
where the * stands for any character.

Please note that the input files are processed 
in the order of the number found in their name. For instance:

"python aggregate.py Fr20125_part2.xml Fr20125_part1.xml -o Fr20125_combined.xml"
"python aggregate.py Fr20125_part1.xml Fr20125_part2.xml -o Fr20125_combined.xml"

both commands will place Fr20125_part1.xml before Fr20125_part2.xml, 
because the script uses "1" and "2" in the name to determine the order.

Q3. How do I tokenise the text?
===============================

"python tokenise.py Fr20125_combined.xml -o Fr20125_tokenised.xml"

In that example Fr20125_combined.xml is your combined TEI input file and 
Fr20125_tokenised.xml is a newly created file with the same content but all 
words marked up with <w> elements.

Q4. How do I generate a KWIC list?
==================================

"python kwic.py Fr20125_tokenised.xml -o Fr20125_kwic.xml"

This will produce a KWIC list xml document from all the tokens found in 
Fr20125_tokenised.xml.

