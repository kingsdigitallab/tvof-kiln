# -*- coding: utf-8 -*-
import glob
import sys
import os
import re
from xml_parser import XMLParser
import xml.etree.ElementTree as ET
from collections import OrderedDict

# TODO
# [DONE] compile
# [DONE] use wildcard
# [DONE] specify output
# . add notes
# [DONE] natural sort of the files
# . sort by id


class Aggregator(XMLParser):

    def __init__(self):
        super(Aggregator, self).__init__()
        self.reset()

    def reset(self):
        self.xml_out = None

    def aggregate(self, input_path):
        print(input_path)

        if not self.read_xml(input_path):
            print '\tWARNING: file is not valid XML'
            return

        # get the body content
        body = self.xml.find('.//body')

        if body is None:
            return

        if self.xml_out is None:
            self.xml_out = self.xml
            return

        body_out = self.xml_out.find('.//body')
        body_out.extend(list(body))

        self.xml = self.xml_out

    def is_aggregating(self):
        return self.xml_out is not None


args = sys.argv

script_file = args.pop(0)

if len(args) < 1:
    print 'Usage: {} INPUT.xml [-o OUTPUT.xml]'.format(os.path.basename(script_file))
    exit()

aggregator = Aggregator()

output_path = u'aggregated.xml'
input_path_list = []
while len(args):
    arg = (args.pop(0)).strip()
    if arg.strip() == '-o':
        if len(args) > 0:
            arg = args.pop(0)
            output_path = arg
    else:
        input_paths = arg

        input_path_list += glob.glob(input_paths)

if input_path_list:
    input_path_list = sorted(input_path_list, key=lambda p: [
                             int(n) for n in re.findall(ur'\d+', p)])
    for input_path in input_path_list:
        if os.path.isfile(input_path):
            aggregator.aggregate(input_path)

if aggregator.is_aggregating():
    aggregator.write_xml(output_path)
    print 'written %s' % output_path
else:
    print 'No input file found, please check the input argument (%s)' % input_paths

print 'done'
