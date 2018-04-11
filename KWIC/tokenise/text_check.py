# -*- coding: utf-8 -*-
import sys
import os
import re
from xml_parser import XMLParser


class TextCheck(XMLParser):

    default_output = u'dummy.xml'
    help = '''
    Report errors in a TEI file:
    * inconsistent seg id, not starting with its parent div id

    '''

    def run_custom(self, input_path_list, output_path):
        for input_path in input_path_list:
            if os.path.isfile(input_path):
                self.check(input_path, output_path)

    def check(self, input_path, output_path):
        ret = False

        self.read_xml(input_path)

        for div in self.xml.findall('.//body/div'):
            divid = div.attrib['{http://www.w3.org/XML/1998/namespace}id']
            sedidx = 0
            for seg in div.findall('./ab/seg'):
                sedidx += 1
                try:
                    segid = seg.attrib['{http://www.w3.org/XML/1998/namespace}id']
                except KeyError:
                    print 'WARNING: seg without an xml:id attribute (under div xml:id="%s")' % divid
                else:
                    if not segid.startswith(divid):
                        print 'WARNING: seg xml:id="%s" under div xml:id="%s"' % (segid, divid)
                        seg.attrib['{http://www.w3.org/XML/1998/namespace}id'] = divid + '_%02d' % sedidx
                

        return ret

TextCheck.run()
