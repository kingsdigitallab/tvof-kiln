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
# . uppercase
# . attach punctuation to words
# [DONE] 7 tokens on each side ! punctuation are also token
# [DONE] same order as legacy kwic
# [DONE] stopwords
# [DONE] duplicates: <item type="seg_item" location="edfr20125_00589" n="5"><string>a</string></item>
# [DONE] remove []


class KWICList(XMLParser):

    stop_words = ['de', 'le', 'o']
    # 'context' size: the number of words on each side of a keyword that are
    # part of its context.
    radius = 7

    def __init__(self):
        super(KWICList, self).__init__()
        print self.namespaces_implicit

    def is_stop_word(self, token):
        '''Return True if <token> in self.stop_words or doesn't contain a letter'''
        return not re.search(ur'(?musi)\w', token) or token in self.stop_words

    def generate_list(self):
        self.make_version('critical')

        # print self.get_unicode_from_xml()

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
                    parent.remove(element)
                    c += 1
            print '\t removed %s %s' % (c, filter)

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
            if keyword:
                keyword = re.sub(ur'[\[\]]', ur'', keyword)
                keywords.append(keyword)
                keyword_tokens.append(token)

        # add tokens metadata to the keyword list
        radius = self.radius + 1
        for i in range(len(keywords)):
            keyword = keywords[i]
            token = keyword_tokens[i]
            self.kwics.append({
                'kw': keyword,
                'sl': keyword.lower()[0:1],
                'lc': parentid,
                'nb': token.attrib.get('n'),
                'tp': 'rubric_item' if element.attrib.get('type') == 'rubric' else 'seg_item',
                'pr': ' '.join(keywords[max(0, i - radius):i]),
                'fo': ' '.join(keywords[i + 1:min(len(keywords), i + radius)]),
            })

    def generate_xml(self):
        print ur'<kwiclist xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema">'
        sublist = None
        for kwic in sorted(self.kwics, key=lambda k: [k['kw'].lower(), k['tp'], k['lc'], int(k['nb'])]):
            if kwic['sl'] != sublist:
                if sublist:
                    print ur'</sublist>'.format(sublist)
                print ur'<sublist key="{}">'.format(kwic['sl'])
                sublist = kwic['sl']
            if not self.is_stop_word(kwic['kw']):
                print u'\t<item type="{tp}" location="{lc}" n="{nb}" preceding="{pr}" following="{fo}">'.format(**kwic)
                print u'\t\t<string>{kw}</string>'.format(**kwic)
                print u'\t</item>'

        if sublist:
            print ur'</sublist>'.format(sublist)
        print ur'</kwiclist>'


args = sys.argv

script_file = args.pop(0)

if len(args) != 1:
    print 'Usage: {} INPUT.xml'.format(os.path.basename(script_file))
    exit()

input_path = args.pop(0)

print input_path

kwic_list = KWICList()
kwic_list.read_xml(input_path)

if kwic_list.generate_list():
    print kwic_list.get_unicode_from_xml()

print 'done'
