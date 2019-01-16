#!/bin/bash

# usage:   ./convertCritShorthand.sh -i temp1/[filename] -o temp2/[filename]

# example: ./convertCritShorthand.sh -i temp1/1_Fr_20125.xml -o temp2/1_Fr_20125.xml

# This shell script takes [filename] in temp1/, runs it through a Perl regex scripts and outputs in temp2/ a new version of the file with encoding in place of the 'shorthand' used in the input file.



FILE_IN="foo"
FILE_OUT="bar"

while getopts ":i:o:" optval "$@"
do
    case $optval in
        "i")
            FILE_IN="$OPTARG"
            echo tweedledum
            ;;
        "o")
            FILE_OUT="$OPTARG"
            echo tweedledee
            ;;
        *)
            errormsg="Unknown parameter or option error with option - $OPTARG"
            echo $errormsg
            exit -1
            ;;
    esac
done

  echo "doing conversion"

  ./regex_4_conversion.perl < $FILE_IN > $FILE_OUT

  echo "okay, all done"

#! /bin/bash
