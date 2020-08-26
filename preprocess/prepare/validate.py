# -*- coding: utf-8 -*-
import sys
import os
import re
from xml_parser import XMLParser
import xml.etree.ElementTree as ET
import io


class Validator(XMLParser):
    '''
    validate a converted.xml (output of convert.py)
    '''

    default_output = u'validation.log'
    suppressed_output = True

    def run_custom(self, input_path_list, output_path):
        if len(input_path_list) != 1:
            print('ERROR: please provide a single input file')
        else:
            self.validation_errors = []
            for input_path in input_path_list:
                self.reset()

                with io.open(input_path, mode="r", encoding="utf-8") as f:
                    content = f.read()

                # 1. XML validity
                if 1:
                    try:
                        self.set_xml_from_unicode(content)
                    except ET.ParseError as e:
                        # xml.etree.ElementTree.ParseError:
                        # mismatched tag: line 40825, column 18
                        self.add_error(
                            'XML validation error: "%s" in %s'
                            % (e.message, input_path)
                        )

                # 2. erase the comments
                # (so we know there won't be special chars there)

                def sub_comment(match):
                    safe_comment = re.sub(r'[^\n]', 'X', match.group(1))
                    ret = '<!--' + safe_comment + '-->'
                    return ret

                content = re.sub(r'(?musi)<!--(.*?)-->',
                                 sub_comment, content)

                # 2. ids
                self.validate_ids(content, input_path)

                # 3. find all special chars
                self.validate_special_chars(content, input_path)

            self.write_errors(output_path)

    def validate_ids(self, content, input_path):
        '''Validate the format of the ids in div and seg elements
          <div n="3ra" type="1" xml:id="edfr20125_00002">
          <seg type="5" xml:id="edfr20125_00002_01">
        '''

        is_royal = re.search('(?i)<title\s+type="main">[^<]*royal', content)
        prefix = 'edfr20125_'
        if is_royal:
            prefix = 'edRoyal20D1_'

        idx = 1
        last_div_id = '_0'
        last_seg_idx = 0
        for line in content.split('\n'):
            if 'type="notes"' in line:
                break
            ids = re.findall(r'<(\w+)[^>]+id="([^"]+)', line)
            for aid in ids:
                if aid[0] == 'div':
                    if not re.match(prefix+r'\d{5}$', aid[1]):
                        print('WARNING: div id format is invalid, %s (line %s, %s)' % (aid[1], idx, input_path))
                    else:
                        if int(aid[1].split('_')[-1]) != 1 + int(last_div_id.split('_')[-1]):
                            print(
                                'WARNING: div id is out of sequence, %s (line %s, %s)' % (
                                aid[1], idx, input_path)
                            )
                        last_div_id = aid[1]
                        last_seg_idx = 0
                if aid[0] == 'seg':
                    expected_seg_id = '%s_%02d' % (last_div_id, last_seg_idx + 1)
                    if not re.match(prefix+r'\d{5}_\d{2}$', aid[1]):
                        print(
                            'WARNING: seg id format is invalid, %s (line %s, %s)' % (aid[1], idx, input_path))
                    elif not aid[1].startswith(last_div_id):
                        print(
                            'WARNING: seg id doesn\'t start with div id, %s (line %s, %s)' % (aid[1], idx, input_path))
                    elif not aid[1] == expected_seg_id:
                        print(
                            'WARNING: seg id out of sequence, %s, expected %s (line %s, %s)' % (aid[1], expected_seg_id, idx, input_path))
                    last_seg_idx += 1

            idx += 1

    def validate_special_chars(self, content, input_path):
        special_chars = u'@%±≠€~`≤Ω{}$*£'

        pattern_char = u'[' + re.escape(special_chars) + u']'
        pattern_cr = re.compile(r'[\n\r]')
        pattern_element = re.compile(
            r'(?musi)<\s*(\w+)\s+[^>]+id="([^"]+)"')

        for match_char in re.finditer(pattern_char, content):
            # print(match_char.start(), match_char.group(0))
            line_number = len(pattern_cr.findall(
                content, 0, match_char.start()
            )) + 1
            match_elements = pattern_element.findall(
                content, 0, match_char.start()
            )
            if match_elements:
                self.add_error(
                    u'%s found in %s id="%s", %s line %s' %
                    (
                        match_char.group(),
                        match_elements[-1][0],
                        match_elements[-1][1],
                        input_path,
                        line_number,
                    )
                )

    def write_errors(self, output_path):
        if self.validation_errors:
            all_errors = '- ' * 10 + '\n'
            all_errors += u'\n'.join(self.validation_errors)
            print(all_errors)
            with open(output_path, 'w+b') as f:
                f.write(all_errors.encode('utf-8'))

    def add_error(self, message):
        self.validation_errors.append(message)


Validator.run()
