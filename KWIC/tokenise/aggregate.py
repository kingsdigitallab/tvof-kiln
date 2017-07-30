# -*- coding: utf-8 -*-
import sys
import os
import re
from xml_parser import XMLParser


class Aggregator(XMLParser):

    default_output = u'aggregated.xml'
    note_order = ['sourceNotes', 'genNotes', 'tradNotes']

    def run_custom(self, input_path_list, output_path):
        input_path_list = sorted(input_path_list, key=lambda p: [
                                 int(n) for n in re.findall(ur'\d+', p)])
        for input_path in input_path_list:
            if os.path.isfile(input_path):
                self.append_tei(input_path)
        self.reorder_content()

        self.add_encoding()

    def add_encoding(self):
        '''
        Add encodingDesc in the header if not there otherwise kiln won't return
        any version when the Text Viewer requests them.
        '''
        if self.xml is None:
            return

        teiHeader = self.xml.find('.//teiHeader')
        if teiHeader is None:
            print '\tWARNING: teiHeader is missing'
            return

        encoding = teiHeader.find('.//encodingDesc')
        if encoding is not None:
            return

        print '\tadd missing encodingDesc element'

        encoding_desc = '''
        <encodingDesc>
          <ab type="version" subtype="semi-diplomatic"/>
          <ab type="version" subtype="interpretive"/>
        </encodingDesc>
        '''
        import xml.etree.ElementTree as ET
        teiHeader.append(ET.fromstring(encoding_desc))

    def append_tei(self, input_path):
        ret = False

        print '\t%s' % input_path

        xml_aggregated = self.xml

        if not self.read_xml(input_path):
            print '\tWARNING: file is not valid XML'
        else:
            # get the body content
            body = self.xml.find('.//body')

            if body is None:
                print '\tWARNING: TEI has no <body> element'
            else:
                if xml_aggregated is None:
                    xml_aggregated = self.xml
                else:
                    xml_aggregated.find('.//body').extend(list(body))

                ret = True

        if ret:
            self.xml = xml_aggregated

        return ret

    def reorder_content(self):
        '''Group all notes by type and move those groups to the end of the document'''
        print '\tgroup all notes and move them to the end'
        # grouping

        if self.xml is None:
            return

        body = self.xml.find('.//body')
        if body is None:
            return

        note_groups = {}

        for note_group in body.findall('div[@type="notes"]'):
            subtype = note_group.attrib.get('subtype')

            if subtype in note_groups:
                # copy notes to the first note group we found
                note_groups[subtype].extend(list(note_group))
                # remove note group
                # (we assume there's no tail)
                body.remove(note_group)
            else:
                note_groups[subtype] = note_group

        # move all note groups at the end of the body
        def get_group_order(note_group):
            ret = 1000
            subtype = note_group.attrib.get('subtype')
            if subtype in self.note_order:
                ret = self.note_order.index(subtype)
            return ret

        body.extend(sorted(note_groups.values(), key=get_group_order))
        for note_group in note_groups.values():
            body.remove(note_group)


Aggregator.run()
