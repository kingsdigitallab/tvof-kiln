# -*- coding: utf-8 -*-
import sys
import os
import re
from xml_parser import XMLParser


class AlignMerge(XMLParser):

    default_output = u'alignment_merged.xml'
    mandatory_files = ['Fr20125', 'Royal_20_D_1']
    is_output_beautified = True

    help = '''
    Merge multiple single-MS alignment files into a single multi-MSS alignment file
    '''

    def run_custom(self, input_path_list, output_path):

        # make sure mandatory files are in input files
        # and place them at the beginning of input_path_list
        for suffix in self.mandatory_files:
            found = 0
            idx = 0
            for path in input_path_list:
                if path.endswith(suffix + '.xml'):
                    found = 1
                    break
                idx += 1
            if found:
                pos = self.mandatory_files.index(suffix)
                input_path_list[pos], input_path_list[idx] = input_path_list[idx], input_path_list[pos]
            else:
                print 'ERROR: missing %s from inputs.' % suffix
                exit()

        print input_path_list

        self.parsed_ms_names = {}

        # merge input files, one by one
        for input_path in input_path_list:
            if os.path.isfile(input_path):
                self.merge_alignment_file(input_path)

    def merge_alignment_file(self, input_path):
        ret = True

        print '\t%s' % input_path

        xml_aggregated = self.xml

        if not self.read_xml(input_path):
            print '\tWARNING: file is not valid XML'
            ret = False

        if ret:
            edition = self.xml.find('.//editionStmt/edition')

            if edition is None:
                print '\tWARNING: file does not contain the MS name <edition n="MS_NAME">'
                ret = False

        if ret:
            ms_name = edition.attrib['n'].strip()

            if ms_name in self.parsed_ms_names:
                print '\tWARNING: edition n="%s" already processed in %s' % (
                    ms_name,
                    self.parsed_ms_names[ms_name]
                )
                ret = False

        if ret:
            self.parsed_ms_names[ms_name] = input_path

            # get the body content
            body = self.xml.find('.//body')

            if body is None:
                print '\tWARNING: TEI has no <body> element'
                ret = False

        if ret:
            if xml_aggregated is None:
                self.remove_other_mss(ms_name)
                xml_aggregated = self.xml
            else:
                self.merge_alignment_ms(xml_aggregated, body, ms_name)

        self.xml = xml_aggregated

        l = 0
        if self.xml is not None:
            print('\t%s' % len(self.get_unicode_from_xml()))

        return ret

    def merge_alignment_ms(self, xml_aggregated, input_body, ms_name):
        '''
        We copy all <ab type="ms_instance"> for ms name = ms_name
        from input_body into the appropriate <div type="alignment">
        in xml_aggregated.
        '''

        para_aggregated_last = None

        for para in input_body.findall('.//div[@type="alignment"]'):
            paraid = para.attrib['{http://www.w3.org/XML/1998/namespace}id']

            para_aggregated = xml_aggregated.find(
                './/div[@{http://www.w3.org/XML/1998/namespace}id="%s"]' % format(
                    paraid
                )
            )

            if para_aggregated is None:
                print '\tWARNING: alignment div not found in the reference file %s' % paraid
                # create it after the last one we've found
                # para_aggregated = para_aggregated_last.
                continue

            for ab in para.findall('.//ab[@type="ms_instance"]'):
                ab_ms_name = ab.find('seg[@type="ms_name"]')
                if ab_ms_name is not None and ab_ms_name.text == ms_name:
                    para_aggregated.append(ab)

            para_aggregated_last = para_aggregated

    def get_unicode_from_xml(self, xml=None):
        ret = super(AlignMerge, self).get_unicode_from_xml()

        ret = re.sub(r'(?musi)<editionStmt>.*</editionStmt>', r'', ret)

        ret = re.sub('\n\s*\n', '\n', ret)

        return ret

    def remove_other_mss(self, ms_name):
        def condition_function(parent, element):
            # <seg type="ms_name">Fr20125</seg>
            ams_name = ''
            seg_ms_name = element.find('seg[@type="ms_name"]')
            if seg_ms_name is not None:
                ams_name = seg_ms_name.text
            return ams_name != ms_name

        self.remove_elements(
            ['ab[@type="ms_instance"]'],
            condition_function
        )


AlignMerge.run()
