# -*- coding: utf-8 -*-
import sys
import os
import re
from xml_parser import XMLParser


class AlignGen(XMLParser):

    default_output = u'alignment_gen.xml'
    help = '''
    Generate alignment XML fragments from a TEI text.
    '''

    def run_custom(self, input_path_list, output_path):
        for input_path in input_path_list:
            if os.path.isfile(input_path):
                self.generate(input_path, output_path)

    def generate(self, input_path, output_path):
        xml_string = self.transform(input_path, 'align_gen.xsl')
        self.set_xml_from_unicode(xml_string)

AlignGen.run()
