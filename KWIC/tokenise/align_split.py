# -*- coding: utf-8 -*-
import sys
import os
import re
from xml_parser import XMLParser


class AlignSplit(XMLParser):

    default_output = u'alignment_MS.xml'

    help = '''
    Extract a single MS alignment file from a multi-MSS alignment file
    '''

    def run_custom(self, input_path_list, output_path):
        for input_path in input_path_list:
            if os.path.isfile(input_path):
                self.split(input_path, output_path)

    def split(self, input_path, output_path):
        ret = False

        print '\t%s' % input_path

        if not getattr(self, 'ms_name', None):
            print('\tERROR: please provide a manuscript name, e.g. -m "Add 19669"')
            exit()

        output_path = output_path.replace('{}', self.ms_name)

        ms_names_keep = [self.ms_name, 'Fr20125']
        #ms_names_keep = [self.ms_name]

        xml_aggregated = self.xml

        if not self.read_xml(input_path):
            print '\tWARNING: file is not valid XML'
        else:
            # get the body content
            body = self.xml.find('.//body')

            if body is None:
                print '\tWARNING: TEI has no <body> element'
            else:
                self.remove_other_mss(ms_names_keep)

                if xml_aggregated is None:
                    xml_aggregated = self.xml
                else:
                    xml_aggregated.find('.//body').extend(list(body))

                ret = True

        if ret:
            self.xml = xml_aggregated

        return ret

    def remove_other_mss(self, ms_names_keep):
        def condition_function(parent, element):
            # <seg type="ms_name">Fr20125</seg>
            ams_name = ''
            seg_ms_name = element.find('seg[@type="ms_name"]')
            if seg_ms_name is not None:
                ams_name = seg_ms_name.text
            return (ams_name not in ms_names_keep) and element.attrib.get(
                'subtype') != 'base'

        self.remove_elements(
            ['ab[@type="ms_instance"]'],
            condition_function
        )

    def get_unicode_from_xml(self, xml=None):
        ret = super(AlignSplit, self).get_unicode_from_xml()

        series = '''
                <editionStmt>
                    <edition n="{0}">{0}</edition>
                </editionStmt>
'''.format(self.ms_name.strip())

        ret = re.sub(r'(</publicationStmt>)', r'\1' + series, ret)

        ret = re.sub('\n\s*\n', '\n', ret)

        return ret


AlignSplit.run()
