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
    elements_to_titles = ['persName', 'placeName', 'geogName', 'name']
    # stop words
    stop_words = ['de', 'le', 'o']
    # 'context' size: the number of words on each side of a keyword that are
    # part of its context.
    context_radius = 7

    def __init__(self):
        super(KWICList, self).__init__()

    def is_stop_word(self, token):
        '''Return True if <token> in self.stop_words or doesn't contain a letter'''
        return not re.search(ur'(?musi)\w', token) or token in self.stop_words

    def generate_list(self):
        self.make_version('critical')

        self.collect_keywords()

        self.generate_xml()

    def make_version(self, version='critical'):
        print 'Create version %s' % version

        if version != 'critical':
            raise Exception('Unsupported version %s' % version)

        filters = ['del', 'orig', 'seg[@type="semi-dip"]', 'sic', 'pb', 'cb']
        for filter in filters:
            c = 0
            matches = re.findall('^([^\[]*)(\[.*\])?', filter)
            tag, condition = matches[0]
            for parent in self.xml.findall(ur'.//*[' + tag + ur']'):
                for element in parent.findall(filter):
                    # We DO NOT use remove as it also delete the tail!
                    # parent.remove(element)
                    tail = element.tail
                    element.clear()
                    element.tail = tail
                    c += 1
            print '\t removed %s %s' % (c, filter)

        print '\t capitalise first letters of name elements'
        for element in self.xml.findall('.//*[@subtype="toUpper"]'):
            element.text = (element.text or ur'').upper()

        # e.g. <persName><w
        # n="9"><choice><reg>J</reg></choice>anus</w></persName>
        for filter in self.elements_to_titles:
            for element in self.xml.findall('.//%s' % filter):
                # print self.get_unicode_from_xml(element)
                # find the first piece of text
                for desc in element.iter():
                    text = (desc.text or ur'')
                    text2 = re.sub(
                        ur'^(\W*)(\w)', lambda m: m.group(1) + m.group(2).upper(), text)
                    # TODO: we should also check the .tail
                    # but 90+% of the time, the first letter is in .text
                    if text != text2:
                        desc.text = text2
                        break
                # print self.get_unicode_from_xml(element)

    def collect_keywords(self):
        self.kwics = []

        for div in self.xml.findall('.//div[head]'):
            parentid = div.attrib.get(self.expand_prefix('xml:id'))
            # for element in div.findall('head[@type="rubric"]',
            # './/seg[@type]'):
            for filter in ['head[@type="rubric"]', './/seg[@type]']:
                for element in div.findall(filter):
                    # only process seg type="1" .. "9"
                    if element.tag == 'seg' and\
                            not re.match(ur'\d+', element.attrib.get('type') or ur''):
                        continue
                    # get ID from seg if available
                    parentid = element.attrib.get(
                        self.expand_prefix('xml:id')) or parentid
                    # add all <w> to the kwic list
                    self.collect_keywords_under_element(element, parentid)

    # Collect all the tokens
    def collect_keywords_under_element(self, element, parentid):
        tokens = element.findall('.//w')

        # collect all the tokens under <element>
        keywords = []
        keyword_tokens = []
        for token in tokens:
            keyword = self.get_element_text(token, True)
            # print parentid, token.attrib.get('n'), repr(self.get_unicode_from_xml(token))
            # print repr(keyword)
            if keyword:
                keyword = re.sub(ur'[\[\]]', ur'', keyword)
                keywords.append(keyword)
                keyword_tokens.append(token)
            else:
                print 'NONE'
                print token.attrib.get('n')
                print parentid
                exit()

        # add tokens metadata to the keyword list
        radius = self.context_radius + 1
        for i in range(len(keywords)):
            keyword = keywords[i]
            token = keyword_tokens[i]
            kwic = {
                'kw': keyword,
                'sl': keyword.lower()[0:1],
                'lc': parentid,
                'nb': token.attrib.get('n'),
                'tp': 'rubric_item' if element.attrib.get('type') == 'rubric' else 'seg_item',
                'pr': ' '.join(keywords[max(0, i - radius):i]),
                'fo': ' '.join(keywords[i + 1:min(len(keywords), i + radius)]),
            }
            # Add ending punctuation mark
            # TODO: detect punctuation before? (actual exceptional)
            # TODO: detect attachment (no space between the two tokens)
            # But again that may be exceptional and not necessarily useful.
            if (i + 1) < len(keywords) and re.match(ur'[\.,]', keywords[i + 1]):
                kwic['pe'] = keywords[i + 1]
            self.kwics.append(kwic)

    def generate_xml(self):
        print 'Generate XML'

        kwic_count = 0

        ret = u''

        ret += u'<kwiclist>'
        sublist = None
        parts = []
        for kwic in sorted(self.kwics, key=lambda k: [k['kw'].lower(), k['tp'], k['lc'], int(k['nb'])]):
            part = u''
            # print u'{lc} {nb} {kw}'.format(**kwic)
            if kwic['sl'] != sublist:
                if sublist:
                    part += ur'</sublist>'.format(sublist)
                part += u'\n<sublist key="{}">'.format(kwic['sl'])
                sublist = kwic['sl']
            if not self.is_stop_word(kwic['kw']):
                part += u'\n\t<item type="{tp}" location="{lc}" n="{nb}" preceding="{pr}" following="{fo}">'.format(
                    **kwic)
                part += u'\n\t\t<string>{kw}</string>'.format(**kwic)
                if kwic.get('pe'):
                    part += u'\n\t\t<punctuation type="end">{pe}</punctuation>'.format(
                        **kwic)
                part += u'\n\t</item>'
                kwic_count += 1
            if part:
                parts.append(part)

        ret += ''.join(parts)

        if sublist:
            ret += u'</sublist>'
        ret += u'</kwiclist>'

        self.set_xml_from_unicode(ret)

        print '%s keywords' % kwic_count

        return ret


args = sys.argv

script_file = args.pop(0)

if len(args) != 1:
    print 'Usage: {} INPUT.xml [OUTPUT.xml]'.format(os.path.basename(script_file))
    exit()

input_path = args.pop(0)

print input_path

kwic_list = KWICList()
kwic_list.read_xml(input_path)

kwic_list.generate_list()

if args:
    output_path = args.pop(0)
else:
    output_path = re.sub(ur'\.[^.]*?$', ur'.kwic.xml', input_path)
if output_path != input_path:
    kwic_list.write_xml(output_path)

print 'written %s' % output_path

print 'done'
