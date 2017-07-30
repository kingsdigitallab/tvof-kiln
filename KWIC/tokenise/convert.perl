#! /usr/bin/perl
# Usage:
#     change_stuff.perl
# 
# IDEMPOTENT VERSION (GN - May 2017)
#
# Where input is from STDIN and output is to STDOUT. Thus, a typical
# invocation would be
#    change_stuff.perl < /path/to/in/file > /path/to/out/file
# or
#    change_stuff.perl < file > file.changed
#
# To use on multiple files, use a loop from the shell
#    for VAR in FILES ; do change_stuff.perl < $VAR > OUTSPEC ; done
# Where OUTSPEC must contain "$VAR" or you get one big file (which is
# likely not what you want). So, for all files in the current working
# directory (or on all marked files in your Emacs dired buffer), issue
#    for f in * ; do change_stuff.perl < $f > $f.fixed ; done
# To experiment only on XML files that start with "b", use
#    for f in b*.xml ; do change_stuff.perl < $f > /tmp/erase.me/$f ; done

# Command line tool to change all occurrences of "foo" to "bar" in the
# files specified. Obviously you replace "foo" and "bar" in the line:
# MEAT_OF_THE_MATTER: s/foo/bar/g;
# with the values you need.
#
# Updated 2003-04-29 by Syd to process entire files out once, rather
# than a line at a time.

use English;

@in = <STDIN>;			# read whole file into one array
$file = join '', @in;		# make it into one big scalar
undef @in;			# don't need this anymore

# now come the substitutions

# $file =~ s|||g;
#

# PRE-PROCESSING

$file =~ s|<\?xml|<MARYPOPPINSxml|g;
$file =~ s|8"\?>|8"MARYPOPPINS>|g;
# GN: temporarly convert named entities, to avoid individual conversion of ; 
$file =~ s|&([a-z]+);|AMPERSAND\1SEMICOLON|gi;
# GN: + is being used within XML attributes, we temporarily convert it
$file =~ s|(=[^>]+?)\+|\1PLUSSIGN|g;
$file =~ s|(=[^>]+?)_|\1UNDERSCORESIGN|g;

# EXTRACT ONLY THE PART THAT NEEDS EXPANSION
my ($before, $file, $after) = ($file =~ /(.+)(<body.+?)((?:body>|<div[^>]+type="notes").+)/s);
#print join("\n------------\n", $before, $file, $after);

# SHORTHAND EXPANSIONS

$file =~ s|\*|<choice><orig></orig><reg>'</reg></choice>|g;

$file =~ s|\$(<pc\srend="[\S]+"/>)([^£]+)£|<choice><seg type="semi-dip">\1\2</seg><seg type="crit">.\2£</seg></choice>|g;
$file =~ s|\$(<pc\srend="[\S]+"/>)([^÷]+)÷|<choice><seg type="semi-dip">\1\2</seg><seg type="crit">.\2÷</seg></choice>|g;


$file =~ s|\$|<choice><orig></orig><reg>.</reg></choice>|g;
$file =~ s|\}|<choice><orig></orig><reg> !</reg></choice>|g;
$file =~ s|¢|<choice><orig></orig><reg>— </reg></choice>|g;
$file =~ s|≤|<choice><orig></orig><reg>·</reg></choice>|g;
$file =~ s|([a-z])£|<choice><seg type="semi-dip">\1</seg><seg type="crit" subtype="toUpper">\1</seg></choice>|g;
$file =~ s|([A-Z])÷|<choice><seg type="semi-dip">\1</seg><seg type="crit" subtype="toLower">\1</seg></choice>|g;


#$file =~ s|\^([\d])|<choice><seg type="semi-dip">\1</seg><seg type="crit" subtype="toSup">\1</seg></choice>|g;
$file =~ s|\^([ivxlcdm])|<hi rend="sup">\1</hi>|g;

# GN: added negative lookbehind assertion to keep the conversion idempotent 
$file =~ s|\?(?!</reg>)|<choice><orig></orig><reg> ?</reg></choice>|g;
# GN: added negative lookbehind assertion to keep the conversion idempotent
# Also avoid converting ; when it is part of a named entity, e.g. &gt; 
$file =~ s|;(?!</reg>)|<choice><orig></orig><reg> ;</reg></choice>|g;
$file =~ s|\{|<choice><orig></orig><reg> :</reg></choice>|g;
$file =~ s|§|<choice><orig></orig><reg>,</reg></choice>|g;
$file =~ s|\+|<choice><orig></orig><reg>« </reg></choice>|g;
$file =~ s|Ω|<choice><orig></orig><reg> »</reg></choice>|g;


$file =~ s|a`|<choice><orig>a</orig><reg>ä</reg></choice>|g;
$file =~ s|e~|<choice><orig>e</orig><reg>é</reg></choice>|g;
$file =~ s|e`|<choice><orig>e</orig><reg>ë</reg></choice>|g;
$file =~ s|i`|<choice><orig>i</orig><reg>ï</reg></choice>|g;
$file =~ s|i,|<choice><orig>i</orig><reg>j</reg></choice>|g;
$file =~ s|i_|<choice><orig>i</orig><reg>J</reg></choice>|g;
# GN: 30 jul 17
$file =~ s|I_|<choice><orig>I</orig><reg>J</reg></choice>|g;
$file =~ s|o`|<choice><orig>o</orig><reg>ö</reg></choice>|g;
# GN: 30 jul 17
$file =~ s|V_|<choice><orig>V</orig><reg>U</reg></choice>|g;
# GN: 30 jul 17
$file =~ s|v,|<choice><orig>v</orig><reg>u</reg></choice>|g;
$file =~ s|u,|<choice><orig>u</orig><reg>v</reg></choice>|g;
# GN: 30 jul 17
$file =~ s|U_|<choice><orig>U</orig><reg>V</reg></choice>|g;
$file =~ s|u_|<choice><orig>u</orig><reg>V</reg></choice>|g;
$file =~ s|u`|<choice><orig>u</orig><reg>ü</reg></choice>|g;

$file =~ s|%([^±]+)±([^≠]+)≠|<choice><seg type="semi-dip">\1\2</seg><seg type="crit">\1 \2</seg></choice>|g;
$file =~ s|@([^€]+)€\s+([^≠]+)≠|<choice><seg type="semi-dip">\1 \2</seg><seg type="crit">\1\2</seg></choice>|g;

# REINSERT THE EXPANDED PART
$file = join('', $before, $file, $after);

# POST-PROCESSING

# GN: place plus signs back into the document 
$file =~ s|PLUSSIGN|+|g;
$file =~ s|UNDERSCORESIGN|_|g;
# GN: place named entities back into the document 
$file =~ s|AMPERSAND(.*?)SEMICOLON|&\1;|gi;
$file =~ s|MARYPOPPINS|?|g;

print $file;			# print out the result

exit;

__DATA__
