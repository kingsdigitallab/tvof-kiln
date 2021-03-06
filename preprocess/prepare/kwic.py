# -*- coding: utf-8 -*-
import sys
import os
import re
from xml_parser import XMLParser
import xml.etree.ElementTree as ET
from collections import OrderedDict

# TODO
# [DONE] only critical
# [DONE] xml format
# [DONE] grouped by keywords
# [DONE] sorted by token
# [DONE] ids
# [DONE] ' missing from keywords
# [DONE] why aal?, aaler?
# [DONE] uppercase
# [DONE] attach punctuation to words
# () add punctuation only if actually attached?
# . <choice>..<seg subtype="toUpper" type="crit">n</seg></choice><choice><orig /><reg>'</reg></choice>
#     . only 7 occurrences, so tempted to ignore it for now
# [DONE] check wellformedness
# [DONE] XML output
# [DONE] 7 tokens on each side ! punctuation are also token
# [DONE] same order as legacy kwic
# [DONE] stopwords
# [DONE] duplicates: <item type="seg_item" location="edfr20125_00589" n="5"><string>a</string></item>
# [DONE] remove []


class KWICList(XMLParser):

    # those elements will have the first letter capitalised in critical version
    # ac-332.4 & ac-337.3
    # see also: is_element_titalised()
    elements_to_titles = ['persName', 'placeName', 'name', 'geogName']
    # ac-276: spaces directly under those elements will be removed
    elements_remove_spaces = ['mod']
    # stop words
    # stop_words = ['de', 'le', 'o']
    stop_words = []
    # 'context' size: the number of words on each side of a keyword that are
    # part of its context.
    context_radius = 7
    default_output = u'kwic.xml'
    elements_to_remove = [
        ur'note',
        # no longer used
        ur'add[@type="annotation"]',
        'pb', 'cb',

        # All below are SEMI-DIPLOMATIC version
        'del', 'orig', 'seg[@type="semi-dip"]', 'sic',

        # ac-329
        'figure',
    ]

    def __init__(self):
        super(KWICList, self).__init__()

    def run_custom(self, input_path_list, output_path):
        if len(input_path_list) != 1:
            print('ERROR: please provide a single input file')
        else:
            for input_path in input_path_list:
                self.read_xml(input_path)
                self.generate_list()
                break

    def generate_list(self):
        self.make_version('critical')

        kwics = self.collect_keywords()

        self.generate_xml(kwics)

    def make_version(self, version='critical'):
        print('Create version %s' % version)

        if version != 'critical':
            raise Exception('Unsupported version %s' % version)

        self.remove_elements(self.elements_to_remove)
        # self.remove_elements(filters)

        print('\t capitalise toUpper')
        for element in self.xml.findall('.//*[@subtype="toUpper"]'):
            element.text = (element.text or ur'').upper()
            for el in element.findall('.//*'):
                el.text = (el.text or ur'').upper()
                el.tail = (el.tail or ur'').upper()

        print('\t lowercase toLower')
        for element in self.xml.findall('.//*[@subtype="toLower"]'):
            element.text = (element.text or ur'').lower()
            for el in element.findall('.//*'):
                el.text = (el.text or ur'').lower()
                el.tail = (el.tail or ur'').lower()

        # remove spaces directly under control elements
        # ac-276:
        # e.g. <w><mod>  <add>a</add> <del>b</del> <mod>c</w>
        # => <w><mod><add>a</add><del>b</del><mod>c</w>

        def collapse_spaces(element, is_tail=False):
            ''' this will remove element.text
            if element.text contains only spaces or line breaks;

            If is_tail= True, apply to element.tail instead
            '''
            part = 'tail' if is_tail else 'text'
            val = getattr(element, part, None)
            if val and not re.search(r'\S', val):
                setattr(element, part, '')

        for tag in self.elements_remove_spaces:
            for element in self.xml.findall('.//' + tag):
                before = self.get_unicode_from_xml(element)
                collapse_spaces(element)
                for child in element:
                    collapse_spaces(child, True)
                after = self.get_unicode_from_xml(element)

                # only enabled when debugging
                if 0 and before != after:
                    print(u'\t`{}` -> `{}`'.format(before, after))

    def collect_keywords(self):
        kwics = []

        for div in self.xml.findall('.//div[head]'):
            paraid = div.attrib.get(self.expand_prefix('xml:id'))

            if not self.is_para_in_range(paraid):
                continue

            # for element in div.findall('head[@type="rubric"]',
            # './/seg[@type]'):
            for filter in ['head[@type="rubric"]', './/seg[@type]']:
                # add all <w> to the kwic list
                kwics.extend(
                    self.collect_keywords_under_elements(
                        div.findall(filter), paraid
                    )
                )

        return kwics

    # Collect all the tokens
    def collect_keywords_under_elements(self, elements, paraid):

        kwics = []

        for element in elements:
            # only process seg type="1" .. "9"
            # also case for 3a, 4a (e.g. Royal)
            if element.tag == 'seg' and\
                    not re.match(ur'\d+[a-z]?$', element.attrib.get('type') or ur''):
                continue

            # get ID from element if available
            elementid = element.attrib.get(
                self.expand_prefix('xml:id')) or paraid

            tokens = element.findall('.//w')

            # collect all the tokens under <element>
            for token in tokens:

                keyword = self.get_element_text(token, True)
                # print parentid, token.attrib.get('n'), repr(self.get_unicode_from_xml(token))
                # print repr(keyword)
                if keyword:
                    keyword = re.sub(ur'[\[\]]', ur'', keyword)
                    # keywords.append(keyword)
                    # keyword_tokens.append(token)
                    kwic = {
                        'kw': keyword,
                        'sl': keyword.lower()[0:1],
                        'lc': elementid,
                        'nb': token.attrib.get('n'),
                        'tp': self.get_token_type_from_parent(element),
                        'sp': self.get_speech_type_from_token(token),
                    }
                    kwics.append(kwic)
                else:
                    print('NONE')
                    print(token.attrib.get('n'))
                    print(paraid)
                    exit()

        # add context (prev/next words) to the new keywords in the list
        radius = self.context_radius + 1
        for i in range(len(kwics)):
            kwic = kwics[i]
            # keyword = keywords[i]
            # token = keyword_tokens[i]

            kwic.update({
                'pr': ' '.join([kw['kw'] for kw in kwics[max(0, i - radius):i]]),
                'fo': ' '.join([kw['kw'] for kw in kwics[i + 1:min(len(kwics), i + radius)]]),
            })

            # Add ending punctuation mark
            # TODO: detect punctuation before? (actual exceptional)
            # TODO: detect attachment (no space between the two tokens)
            # But again that may be exceptional and not necessarily useful.
            if (i + 1) < len(kwics) and re.match(ur'[\.,]', kwics[i + 1]['kw']):
                kwic['pe'] = kwics[i + 1]['kw']

        return kwics

    def get_speech_type_from_token(self, token):
        ret = ''

        speech_elements = getattr(self, 'speech_elements', None)
        if speech_elements is None:
            # <said direct="false">de tout
            speech_elements = {
                'direct': {id(e): 1 for e in self.xml.findall(".//said[@direct='true']//w")},
                'indirect': {id(e): 1 for e in self.xml.findall(".//said[@direct='false']//w")},
            }
            self.speech_elements = speech_elements
        else:
            if id(token) in speech_elements['direct']:
                ret = 'direct'
            elif id(token) in speech_elements['indirect']:
                ret = 'indirect'

        return ret

    def get_token_type_from_parent(self, parent):
        '''Returns the token type from the @type of the parent of the token'''
        ret = 'seg_item'

        el_type = parent.attrib.get('type')
        if el_type == 'rubric':
            ret = 'rubric_item'
        if el_type == '6':
            ret = 'verse_item'

        return ret

    def generate_xml(self, kwics):
        print('Generate XML')

        kwic_count = 0

        ret = u''

        ret += u'<kwiclist>'
        sublist = None
        parts = []
        invalids = {}
        for kwic in sorted(kwics, key=lambda k: [k['kw'].lower(), k['tp'], k['lc'], int(k['nb'])]):
            is_token_invalid = (
                re.search(ur'\s', kwic['kw'])
                or len(kwic['kw']) > 20
                or not(kwic['kw'])
            )
            if is_token_invalid:
                if kwic['kw'] not in invalids:
                    print('WARNING: probably invalid token in %s, "%s".' %
                          (kwic['lc'], repr(kwic['kw'])))
                    invalids[kwic['kw']] = 1
                continue

            for k in ['sl', 'pr', 'fo', 'kw', 'pe']:
                v = kwic.get(k, None)
                if v is not None:
                    kwic[k] = v.replace('"', '&quot;')

            part = u''
            # print u'{lc} {nb} {kw}'.format(**kwic)
            if kwic['sl'] != sublist:
                if sublist:
                    part += ur'</sublist>'.format(sublist)
                part += u'\n<sublist key="{}">'.format(kwic['sl'])
                sublist = kwic['sl']
            if not self.is_stop_word(kwic['kw']):
                part += u'\n\t<item type="{tp}" location="{lc}" n="{nb}" preceding="{pr}" following="{fo}" sp="{sp}">'.format(
                    **kwic)
                part += u'\n\t\t<string>{kw}</string>'.format(**kwic)
                if kwic.get('pe'):
                    part += u'\n\t\t<punctuation type="end">{pe}</punctuation>'.format(
                        **kwic)
                part += u'\n\t</item>'
                kwic_count += 1

            if part:
                parts.append(part)

#         for kwic in sorted(set([k['kw'] for k in self.kwics])):
#             print repr(kwic)

        ret += ''.join(parts)

        if sublist:
            ret += u'</sublist>'
        ret += u'</kwiclist>'

        if 0:
            # for debugging only: output notwelformedfile
            file_path = 'notwellformed.xml'
            encoding = 'utf-8'
            f = open(file_path, 'wb')
            content = u'<?xml version="1.0" encoding="{}"?>\n'.format(encoding)
            content += ret
            content = content.encode(encoding)
            f.write(content)
            f.close()

        self.set_xml_from_unicode(ret)

        print('%s keywords' % kwic_count)

        return ret

    def is_element_titalised(self, element):
        # see ac-343
        return True

        ret = True

        # ac-332.4 removed <name type="building">
        # print(element.tag, element.attrib.get('type', ''))
        if element.attrib.get('type', '').lower() in ['building']:
            ret = False

        return ret

    def is_stop_word(self, token):
        '''Return True if <token> in self.stop_words or doesn't contain a letter'''
        return not re.search(ur'(?musi)\w', token) or token in self.stop_words


KWICList.run()
