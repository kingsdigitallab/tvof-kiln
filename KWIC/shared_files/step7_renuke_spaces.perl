#! /usr/bin/perl
# Usage:
#     change_stuff.perl
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
## with the values you need.
#
# Updated 2003-04-29 by Syd to process entire files out once, rather
# than a line at a time.

use English;

@in = <STDIN>;			# read whole file into one array
$file = join '', @in;		# make it into one big scalar
undef @in;			# don't need this anymore

# now come the substitutions

# $file =~ s|||g;

# these two handle the parent <choice> , whatever the children
$file =~ s|\s[\s]+| |g;

print $file;			# print out the result

exit;

__DATA__
