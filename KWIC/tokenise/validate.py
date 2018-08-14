# -*- coding: utf-8 -*-
import sys
import os
import re
from xml_parser import XMLParser
import xml.etree.ElementTree as ET
import io


class Validator(XMLParser):

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

                try:
                    ET.fromstring(content.encode('utf-8'))
                except ET.ParseError as e:
                    # xml.etree.ElementTree.ParseError:
                    # mismatched tag: line 40825, column 18
                    self.add_error(
                        'XML validation error: "%s" in %s'
                        % (e.message, input_path)
                    )

                # 1. erase the comments
                # (so we know there won't be special chars there)
                def sub_comment(match):
                    safe_comment = re.sub(r'[^\n]', 'X', match.group(1))
                    ret = '<!--' + safe_comment + '-->'
                    return ret

                content = re.sub(r'(?musi)<!--(.*?)-->',
                                 sub_comment, content)

                # 2. find all special chars

                special_chars = u'@%±≠€~`≤Ω{}$*£'

                pattern_char = u'[' + re.escape(special_chars) + u']'
                pattern_cr = re.compile(r'[\n\r]')
                pattern_element = re.compile(
                    r'(?musi)<\s*(\w+)\s+[^>]+id="([^"]+)"')

                for match_char in re.finditer(pattern_char, content):
                    #print(match_char.start(), match_char.group(0))
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

            self.write_errors(output_path)

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
