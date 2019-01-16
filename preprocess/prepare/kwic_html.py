# -*- coding: utf-8 -*-
import sys
import os
import re
from xml_parser import XMLParser
import xml.etree.ElementTree as ET


class KwicHtml(XMLParser):

    default_output = u'kwic.html'

    def run_custom(self, input_path_list, output_path):
        if len(input_path_list) != 1:
            print 'ERROR: please provide a single input file'
        else:
            for input_path in input_path_list:
                self.reset()
                if not self.read_xml(input_path):
                    raise Exception('Cant read %s' % input_path)
                self.convert_to_html()
                break

    def convert_to_html(self):
        ret = ''

        self.templates = templates = {}
        templates['sublist'] = u'''
<h2>
    {{ @key }}
</h2>
<table>
    {{ items }}
</table>
'''
        templates['document'] = self.load_template('kwic.template.html')
        templates['item'] = self.load_template('kwic.item.template.html')

        sublists = []

        for sublist in self.xml.findall(ur'sublist'):
            context = {
                'element': sublist,
                'items': self.render_items(sublist)
            }
            sublists.append(self.render('sublist', context))

        context = {
            'sublists': u'\n'.join(sublists)
        }
        ret = self.render('document', context)

        self.set_xml_from_unicode(ret)

    def render_items(self, sublist):
        ret = []

        for item in sublist.findall(ur'item'):
            context = {
                'element': item,
            }
            ret.append(self.render('item', context))

        return u'\n'.join(ret)

    def render(self, template_name, context):
        ret = self.templates[template_name]

        def replace(match):
            ret = match.group(0)
            k = match.group(1)

            if k.startswith('@'):
                ret = context['element'].get(k[1:])
            elif k.startswith('/'):
                ret = context['element'].find(k[1:])
                if ret is not None:
                    ret = ret.text
                else:
                    ret = ''
            else:
                ret = context[k]

            return ret

        ret = re.sub(u'{{\s*(\S+)\s*}}', replace, ret)

        return ret

    def load_template(self, filepath):
        import codecs
        with codecs.open(filepath, 'r', 'utf-8') as f:
            ret = f.read()
        return ret


KwicHtml.run()
