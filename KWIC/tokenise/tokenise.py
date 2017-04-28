# -*- coding: utf-8 -*-
import sys
import os
import re
from xml_parser import XMLParser
import xml.etree.ElementTree as ET


class TEITokeniser(XMLParser):

    token_start = u'#{#'
    token_end = u'#}#'
    tag_to_be_remove = u'TOBEREMOVED'
    default_output = u'tokenised.xml'

    def run_custom(self, input_path_list, output_path):
        if len(input_path_list) != 1:
            print 'ERROR: please provide a single input file'
        else:
            for input_path in input_path_list:
                self.reset()
                self.read_xml(input_path)

                if self.tokenise():
                    # tokeniser.find_corner_cases()

                    self.assign_tokenids()
                    # print tokeniser.get_unicode_from_xml()

    def remove_superfluous_spaces(self):
        # Remove spaces erroneously added by Oxygen editor.
        # They can disrupt the tokenisation.
        # See step0_nuke_spaces.perl
        xml_string = self.get_unicode_from_xml()

        xml_string = re.sub(ur'(?musi)(<choice>)\s+', ur'\1', xml_string)

        self.set_xml_from_unicode(xml_string)

    def find_corner_cases(self):
        body = self.xml.find('.//body', 'tei')

        xml_string = self.get_unicode_from_xml()

        # see how many <choice><seg type="crit"> contain a space
        # AND the words inside are not complete
        # because this then pauses a problem to the tokenisation
        #
        # Only cases found are like for !, e.g.
        # estoient<choice><seg type="semi-dip" /><seg type="crit">
        # !</seg></choice>
        if 0:
            for choice in re.findall(ur'(?musi)((\w*)<choice>.*?</choice>(\w*))', xml_string):
                if any([choice[1], choice[2]]):
                    segs = re.findall(
                        ur'(?musi)<seg type="crit">([^<]+)</seg>', choice[0])
                    if segs and re.search(ur'(?musi)\s', segs[0]):
                        print choice[0]

        # find nested tokens
        # <w><choice><seg type="semi-dip">separti</seg><seg type="crit"><w>se</w> <w>parti</w></seg></choice></w>
        if 1:
            i = 0
            for word in body.findall('.//w'):
                subwords = word.find('.//w')
                if subwords is not None:
                    print i, ET.tostring(word)
                    i += 1

    def convert_string_tokens_to_xml(self):
        # Turn annotation into XML elements.
        # Do this on a string serialisation of the XML doc.
        xml_string = self.get_unicode_from_xml()
        xml_string = re.sub(self.token_start, ur'<w>', xml_string)
        xml_string = re.sub(self.token_end, ur'</w>', xml_string)

        # remove tags marked for deletion
        xml_string = re.sub(
            ur'<\s*/?\s*' + self.tag_to_be_remove + ur'\s*/?\s*>', '', xml_string)

        ret = self.is_wellformed(xml_string)
        if ret:
            self.set_xml_from_unicode(xml_string)
        else:
            print xml_string
            exit()

        return ret

    def tokenise_text(self, el, part, pos=0, el_prev=None, part_prev=None):
        el_txt = [el, part]

        text = getattr(el, part) or ur''

        # scind around punctuation
        text = re.sub(ur"(?musi)([^'\s\w\[\]·])", self.token_end +
                      self.token_start +
                      ur'\1' + self.token_end + self.token_start, text)

        # scind around spaces
        text = re.sub(ur'(\s+)', self.token_end +
                      ur'\1' + self.token_start, text)

        if pos == -1:
            text = self.token_start + text

        if el.tag == 'choice' and part == 'tail':
            for reg in [el.find('reg'), el.find('seg[@type="crit"]')]:
                # special case for apostrophe, it is part of the previous
                # token but not part of the text coming after
                if reg is not None and reg.text:
                    apostrophe = reg.text[-1] in ["'"]
                    punctuation = 1 and not re.search(
                        ur'(?musi)\w', reg.text)
                    if apostrophe or punctuation:
                        # scind it after
                        text = self.token_end + self.token_start + text
                    if punctuation and not apostrophe and not list(reg):
                        if el_prev is not None:
                            # scind it before
                            text_prev = getattr(
                                el_prev, part_prev) or ur''
                            text_prev += self.token_end + self.token_start
                            setattr(el_prev, part_prev, text_prev)

        setattr(el, part, text)

        el_txt.append(text)

        return el_txt

    def push_down_tokens(self):
        ret = False

        for word in self.xml.findall('.//w'):

            # skip if has any text
            if re.search(ur'(?musi)\S', self.get_element_text(word)):
                continue

            word.tag = self.tag_to_be_remove
            ret = True

            children = list(word)

            # remove empty <w>
            if not children and not self.get_element_text(word):
                continue

            for child in children:
                if (child.attrib.get('type', None) == 'notes'):
                    continue
                last = self.tokenise_text(child, 'text', -1)
                for subchild in list(child):
                    last = self.tokenise_text(
                        subchild, 'tail', 0, last[0], last[1])

                setattr(last[0], last[1], last[2] + self.token_end)

        if ret:
            self.convert_string_tokens_to_xml()

        # if transforms applied, redo the whole nesting-removal task on the
        # whole text. This is to push tokenisation deeper into the tree.
        # self.remove_nested_tokens()

        return ret

    def tokenise(self):
        ret = True
        self.remove_superfluous_spaces()

        xml_string = self.get_unicode_from_xml()
        xml_string = re.sub(ur'<\s*body\s*>', ur'<w><body>', xml_string)
        xml_string = re.sub(ur'<\s*/\s*body\s*>', ur'</body></w>', xml_string)
        self.set_xml_from_unicode(xml_string)

        # self.find_corner_cases()
        #body = self.xml.find('.//body')
        # self.push_down_tokens(body)
        # self.convert_string_tokens_to_xml()

        if 1:
            pass_count = 0
            while True:
                pass_count += 1
                print 'pass %s' % pass_count

                changed = self.push_down_tokens()
                if not changed:
                    break
                if pass_count > 12:
                    break

        return ret

    def assign_tokenids(self):
        # we assign a sequential id for each <w> relative to their parent id
        for parent in self.xml.findall(self.expand_prefix('.//*[@xml:id]')):
            relativeid = 0
            for child in parent.findall('.//w'):
                relativeid += 1
                child.attrib['n'] = unicode(relativeid)


TEITokeniser.run()
