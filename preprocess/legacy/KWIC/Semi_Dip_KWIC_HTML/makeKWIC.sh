#!/bin/bash

# usage:   ./makeKWIC.sh -i temp1/[filename] -o temp2/[filename]_KWIClist.html -l yes

# example: ./makeKWIC.sh -i temp1/1_Fr_20125.xml -o temp2/1_Fr_20125_KWIClist.html -l yes

# if -l is not used, it defaults to not using the stop word list

# This shell script takes [filename] in temp1/, runs it through three XSL transformations
# and outputs a KWIC display as [filename]_KWIClist.html in temp2/




FILE_IN="foo"
FILE_OUT="bar"
USE_STOPLIST="no"

while getopts ":i:o:l:" optval "$@"
do
    case $optval in
        "i")
            FILE_IN="$OPTARG"
            echo snap
            ;;
        "o")
            FILE_OUT="$OPTARG"
            echo crackle
            ;;
        "l")
            USE_STOPLIST="$OPTARG"
            echo pop
            ;;
        *)
            errormsg="Unknown parameter or option error with option - $OPTARG"
            echo $errormsg
            exit -1
            ;;
    esac
done


out=$FILE_OUT
outpath=${out%/*}
outname=${out##/*/}
outname=${outname#./}
outroot=${outname%.*}
tempbase="/tmp/${outroot}_temp"
mkdir -p $tempbase
temp00="${tempbase}00"
temp01="${tempbase}01"
temp02="${tempbase}02"
temp03="${tempbase}03"
temp04="${tempbase}04"
temp05="${tempbase}05"
temp06="${tempbase}06"
temp07="${tempbase}07"



echo "step 0: nuking stupid unwanted oXygen spaces"

./../shared_files/step0_nuke_spaces.perl < $FILE_IN > $temp00

echo "step 1: adding case markers for name elements"

/usr/bin/java -jar ../shared_files/saxon9he.jar -o:$temp01 -s:$temp00 -xsl:../shared_files/step1_add_case_markers.xsl version="semi-diplomatic"
echo "step 2: making semi-diplomatic version"

/usr/bin/java -jar ../shared_files/saxon9he.jar -o:$temp02 -s:$temp01 -xsl:../shared_files/step2_make_version.xsl version="semi-diplomatic"

echo "step 3: realizing punctuation chars"

/usr/bin/java -jar ../shared_files/saxon9he.jar -o:$temp03 -s:$temp02 -xsl:../shared_files/step3_make_puncts.xsl version="semi-diplomatic"

echo "step 4: creating word elements"

/usr/bin/java -jar ../shared_files/saxon9he.jar -o:$temp04 -s:$temp03 -xsl:../shared_files/step4_make_words.xsl version="semi-diplomatic"

echo "step 5: creating item elements"

/usr/bin/java -jar ../shared_files/saxon9he.jar -o:$temp05 -s:$temp04 -xsl:../shared_files/step5_make_items.xsl version="semi-diplomatic"

echo "step 6: creating list of sorted items"

/usr/bin/java -jar ../shared_files/saxon9he.jar -o:$temp06 -s:$temp05 -xsl:../shared_files/step6_sort_items.xsl version="semi-diplomatic" use_stoplist=$USE_STOPLIST

echo "step 7: nuking more stupid unwanted oXygen spaces"

./../shared_files/step7_renuke_spaces.perl < $temp06 > $temp07

echo "step 8: creating KWIC display HTML page"

/usr/bin/java -jar ../shared_files/saxon9he.jar -o:$FILE_OUT -s:$temp07 -xsl:../shared_files/step8_make_HTML.xsl

echo "okay, all done"

#! /bin/bash
