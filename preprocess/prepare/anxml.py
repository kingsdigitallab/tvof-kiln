import sys
import os
import re

args = sys.argv

script_file = args.pop(0)

#


def read_file(filepath):
    import codecs
    f = codecs.open(filepath, 'r', "utf-8")
    ret = f.read()
    f.close()

    return ret


if len(args) != 1:
    print 'Usage: {} INPUT.xml'.format(os.path.basename(script_file))
    exit()

input_path = args.pop(0)

# read XML
xml = read_file(input_path)

# remove attr with unique ids
xml = re.sub('xml:id=".*?"', '', xml)
xml = re.sub('corresp=".*?"', '', xml)
xml = re.sub(ur'(?musi)<teiHeader>.*</teiHeader>', '', xml)

els = {}
for el in re.findall(ur'(?musi)<[^>]+>', xml):
    if el[1] in ['/', '!', '?']:
        continue
    el = re.sub(ur'(?musi)\s+', ' ', el)
    els[el] = 1

print '\n'.join(sorted(els.keys()))
