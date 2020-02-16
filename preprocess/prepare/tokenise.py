# -*- coding: utf-8 -*-
import sys
import os
import re
from xml_parser import XMLParser
import xml.etree.ElementTree as ET

# how deep the tokenisation has to go
MAX_TOKENISATION_DEPTH = 15
# 1 for debugging only, easy to compare 2 tokenised files
# b/c word numbers are all set to 0
DEBUG_SAME_WORD_NUMBER = 0


class TEITokeniser(XMLParser):

    token_start = u'#{#'
    token_end = u'#}#'
    tag_to_be_remove = u'TOBEREMOVED'
    default_output = u'tokenised.xml'
    # DONT remove anything! tokenisation should be lossless so we
    # can reverse the process.
    elements_to_remove = []
#     elements_to_remove = [
#         ur'note',
#         ur'add[@type="annotation"]',
#     ]

    def run_custom(self, input_path_list, output_path):
        if len(input_path_list) != 1:
            print('ERROR: please provide a single input file')
        else:
            for input_path in input_path_list:
                self.reset()
                if not self.read_xml(input_path):
                    raise Exception('Cant read %s' % input_path)

                if self.tokenise():
                    # tokeniser.find_corner_cases()

                    self.assign_tokenids()
                    # print tokeniser.get_unicode_from_xml()

                    if 0:
                        # disabled as this validation is verbose and already
                        # done by kwic.py
                        self._report_tokenisation_errors()

            self.forget_xml_comments()

    def tokenise(self):
        ret = True

        # remove some elements we don't want to show on website or lemmatise
        self.remove_elements(self.elements_to_remove)

        self.remove_superfluous_spaces()

        xml_string = self.get_unicode_from_xml()
        xml_string = re.sub(ur'<\s*body\s*>', ur'<w><body>', xml_string)
        xml_string = re.sub(ur'<\s*/\s*body\s*>', ur'</body></w>', xml_string)
        self.set_xml_from_unicode(xml_string)

        # self.find_corner_cases()

        pass_count = 0
        while True:
            pass_count += 1
            print('\tpass %s' % pass_count)

            changed = self.push_down_tokens()
            if not changed:
                break
            if pass_count > MAX_TOKENISATION_DEPTH:
                break

        return ret

    def remove_superfluous_spaces(self):
        # Remove spaces erroneously added by Oxygen editor.
        # They can disrupt the tokenisation.
        # See step0_nuke_spaces.perl
        xml_string = self.get_unicode_from_xml()

        xml_string = re.sub(ur'(?musi)(<choice>)\s+', ur'\1', xml_string)

        self.set_xml_from_unicode(xml_string)

    def push_down_tokens(self):
        ret = False

        for word in self.xml.findall('.//w'):

            # skip if has any text
            if re.search(ur'(?musi)\S', self.get_element_text(word)):
                continue

            children = list(word)

            if 1:
                # TODO: skip if more than one child with text
                # AC-376
                # <a>v1</a><b>v2</b> <c>v3</c>
                # =>
                # <w><a>v1</a><b>v2</b></w> <c><w>v3</w></c>
                # Basically we don't want to split v1 and v2
                # TODO:
                # <a>v1 </a>v2 => <a>v1</a> v2
                # And other direction
                children_with_text = len([
                    c
                    for c
                    in children
                    if self.get_element_text(c, True)
                    and c.tag not in ['figure']
                ])

                if children_with_text == 2 and (
                    children[0].tag in ['orig', 'reg', 'sic', 'corr']
                    or children[0].attrib.get('type', '') in ['semi-dip', 'crit']
                ):
                    # exception, in some cases the choice constructs two
                    # alternative (sets of) tokens
                    # e.g. <choice><orig>a</orig><reg>A</reg></choice>
                    # <choice><seg type="semi-dip">porce</seg><seg type="crit">por ce</seg></choice>
                    pass
                else:
                    if children_with_text > 1:
                        continue

            word.tag = self.tag_to_be_remove
            ret = True

            # remove empty <w>
            if not children and not self.get_element_text(word):
                continue

            for child in children:
                # TODO: ignore annotation and note like here
                # rather than removing them.
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

    def tokenise_text(self, el, part, pos=0, el_prev=None, part_prev=None):
        el_txt = [el, part]

        text = getattr(el, part) or ur''

        # split around punctuation
        text = re.sub(ur"(?musi)([^'\s\w\[\]·])", self.token_end +
                      self.token_start +
                      ur'\1' + self.token_end + self.token_start, text)

        # split around spaces
        text = re.sub(ur'(?u)(\s+)', self.token_end +
                      ur'\1' + self.token_start, text)

        if pos == -1:
            text = self.token_start + text

        if el.tag == 'choice' and part == 'tail':
            for reg in [el.find('reg'), el.find('seg[@type="crit"]')]:
                # special case for apostrophe, it is part of the previous
                # token but not part of the text coming after
                # qu<choice><orig></orig><reg>'</reg></choice>eles
                #
                # <choice><orig>entreamoient</orig><reg>entre'amoient</reg></choice>
                # <choice><orig>entrespargnoient</orig><reg>entr'espargnoient</reg></choice>
                if reg is not None and reg.text:
                    apostrophe = reg.text[-1] in ["'"]
                    # any character in reg?
                    punctuation = 1 and not re.search(
                        ur'(?musi)[\w·]', reg.text)
                    if apostrophe or punctuation:
                        # scind it after
                        # => qu<choice><orig></orig><reg>'</reg></choice></w><w>eles
                        text = self.token_end + self.token_start + text
                    if punctuation and not apostrophe and not list(reg):
                        # => <seg type="semi-dip"></seg><w><seg type="crit">.</seg></w></choice></seg>
                        # => <seg type="semi-dip"></seg><w><seg type="crit"> !</seg></w></choice></seg>
                        if el_prev is not None:
                            # scind it before
                            text_prev = getattr(
                                el_prev, part_prev) or ur''
                            text_prev += self.token_end + self.token_start
                            setattr(el_prev, part_prev, text_prev)

        # split around tei punctuation
        if el.tag == 'pc' and part == 'tail':
            # e.g. <a>x<b><pc rend="1">xy
            # => <a>x<b></w><pc rend="1"><w>xy
            text_prev = getattr(el_prev, part_prev) or ur''
            setattr(el_prev, part_prev, text_prev + self.token_end)
            text = self.token_start + text

        setattr(el, part, text)

        el_txt.append(text)

        return el_txt

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
            print(xml_string)
            exit()

        return ret

    def assign_tokenids(self):
        # we assign a sequential id for each <w> relative to their parent id
        for parent in self.xml.findall(self.expand_prefix('.//*[@xml:id]')):
            relativeid = 0
            for child in parent.findall('.//w'):
                if not DEBUG_SAME_WORD_NUMBER:
                    relativeid += 1
                child.attrib['n'] = unicode(relativeid)

    def find_corner_cases(self):
        '''Still needed?'''
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
                        print(choice[0])

        # find nested tokens
        # <w><choice><seg type="semi-dip">separti</seg><seg type="crit"><w>se</w> <w>parti</w></seg></choice></w>
        if 1:
            i = 0
            for word in body.findall('.//w'):
                subwords = word.find('.//w')
                if subwords is not None:
                    print(i, ET.tostring(word))
                    i += 1

    def _report_tokenisation_errors(self):
        def check_child_words(location, words):
            for w in words:
                text = self.get_element_text(w, 1)
                if re.search(ur"(?u)\s", text):
                    print(
                        u'WARNING: more than one word in id="%s" <w n="%s"> (%s)' % (
                            location,
                            w.attrib.get('n', ''),
                            text,
                        )
                    )

        for div in self.xml.findall(r'.//div[@type="1"]'):
            location = div.attrib.get(self.expand_prefix('xml:id'), '')
            if not location:
                continue

            check_child_words(location, div.findall('.//head//w'))

            for seg in div.findall('.//seg'):
                location = seg.attrib.get(self.expand_prefix('xml:id'), '')
                if location:
                    check_child_words(location, seg.findall('.//w'))


TEITokeniser.run()
