# -*- coding: utf-8 -*-
import sys
import os
import re
import xml.etree.ElementTree as ET


class XMLParser(object):

    def __init__(self):
        self.namespaces_implicit = {
            'xml': 'http://www.w3.org/XML/1998/namespace',
        }
        self.xml = None

    def set_namespaces_from_unicode(self, xml_string):
        # grab all the namespaces
        self.namespaces = {
            prefix: uri
            for definition, prefix, uri
            in re.findall(ur'(xmlns(:\w+)?\s*=\s*"([^"]+)")', xml_string)
        }
        self.namespaces.update(self.namespaces_implicit)

    def set_xml_from_unicode(self, xml_string):
        # grab all the namespaces
        self.set_namespaces_from_unicode(xml_string)

        # remove the default namespace definition
        # to simplify parsing
        # we'll put it back in get_unicode_from_xml()
        xml_string = re.sub(ur'\sxmlns="[^"]+"', '', xml_string, count=1)

        # note that ET takes a utf-8 encoded string
        self.xml = ET.fromstring(xml_string.encode('utf-8'))

    def get_unicode_from_xml(self, xml=None):
        if xml is None:
            for prefix, url in self.namespaces.iteritems():
                # skip xml namespace, it's implicitly defined
                if prefix == 'xml':
                    continue
                aprefix = 'xmlns'
                if prefix:
                    aprefix += ':' + prefix
                self.xml.set(aprefix, url)

        if xml is None:
            xml = self.xml

        return ET.tostring(xml, encoding='utf-8').decode('utf-8')

    def read_xml(self, filepath):
        import codecs
        with codecs.open(filepath, 'r', 'utf-8') as f:
            content = f.read()

            self.set_xml_from_unicode(content)

    def write_xml(self, file_path, encoding='utf-8'):
        f = open(file_path, 'wb')
        if encoding:
            content = ur'<?xml version="1.0" encoding="{}"?>'.format(encoding)
            content += self.get_unicode_from_xml()
            content = content.encode(encoding)
        f.write(content)
        f.close()

    def get_element_text(self, element, recursive=False):
        if recursive:
            ret = element.itertext()
        else:
            ret = [(element.text or u'')] +\
                [(child.tail or u'') for child in list(element)]

        return u''.join(ret)

    def expand_prefix(self, expression):
        expression = re.sub(
            ur'(\w+):',
            lambda m: ur'{%s}' % self.namespaces[m.group(1)],
            expression
        )
        return expression

    def is_wellformed(self, xml_string):
        ret = True

        try:
            xml_string = ET.fromstring(xml_string.encode('utf-8'))
        except ET.ParseError, e:
            print u'%s' % e
            # (3056, 242) = (line, char)
            lines = xml_string.split('\n')
            print lines[e.position[0] - 1]
            print (' ' * (e.position[1] - 1)) + '^'
            ret = False

        return ret
