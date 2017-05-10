# -*- coding: utf-8 -*-
import sys
import os
import re
from xml_parser import XMLParser
import xml.etree.ElementTree as ET
from collections import OrderedDict


class ParseAll(XMLParser):

    suppressed_output = True
    default_output = u''

    def run_custom(self, input_path_list, output_path):

        # aggregate
        print '-' * 20
        outfiles = [output_path + 'aggregated.xml']
        from aggregate import Aggregator
        options = input_path_list + ['-o', outfiles[-1]]
        Aggregator.run(options)

        # convert shorthands
        print '-' * 20
        outfiles += [output_path + 'converted.xml']
        command = 'perl convert.perl < %s > %s' %\
                  (outfiles[-2], outfiles[-1])
        print command
        os.system(command)

        # tokenise
        print '-' * 20
        outfiles += [output_path + 'tokenised.xml']
        from tokenise import TEITokeniser
        options = [outfiles[-2]] + ['-o', outfiles[-1]]
        TEITokeniser.run(options)

        # kwic
        print '-' * 20
        outfiles += [output_path + 'kwic.xml']
        from kwic import KWICList
        options = [outfiles[-2]] + ['-o', outfiles[-1]]
        KWICList.run(options)


ParseAll.run()
