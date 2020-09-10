# -*- coding: utf-8 -*-
import sys
import os
import re
import glob
import datetime
import xml.etree.ElementTree as ET


class XMLParser(object):

    suppressed_output = False
    default_output = u'parsed.xml'
    # TODO: implement this, but not possible with ElementTree...
    is_output_beautified = False

    def __init__(self):
        self.convert_only = False
        self.xml_comments = []
        self.reset()

    def reset(self):
        self.paragraphs = []
        self.namespaces_implicit = {
            'xml': 'http://www.w3.org/XML/1998/namespace',
        }
        self.xml = None

    def has_xml(self):
        return self.xml is not None

    def transform(self, xml_path, xsl_path):
        import lxml.etree as LET

        dom = LET.parse(xml_path)
        xslt = LET.parse(xsl_path)
        trans = LET.XSLT(xslt)
        newdom = trans(dom)
        ret = LET.tostring(newdom, pretty_print=True)

        # 2-space indent -> 4-space indent
        ret = re.sub(r'(?m)^ +', lambda m: ' ' * (2 * len(m.group(0))), ret)

        return ret

    @classmethod
    def run(cls, args=None):
        if args is None and cls.__module__ != '__main__':
            return

        script_file = '%s.py' % cls.__module__

        if args is None:
            args = sys.argv
            script_file = args.pop(0)

        parser = cls()

        print('python2 %s %s' % (script_file, ' '.join(args)))

        if len(args) < 1:
            print(
                'Usage: {} INPUT.xml [-o OUTPUT.xml] [-r PARA_RANGE]'.format(
                    os.path.basename(script_file)))
            exit()

        output_path = cls.default_output
        input_str = []
        input_path_list = []
        while len(args):
            arg = (args.pop(0)).strip()
            if arg.strip() == '-r':
                if len(args) > 0:
                    arg = args.pop(0)
                    parser.set_paragraphs(arg)
            elif arg.strip() == '-o':
                if len(args) > 0:
                    arg = args.pop(0)
                    output_path = arg
            elif arg.strip() == '-m':
                if len(args) > 0:
                    arg = args.pop(0)
                    parser.ms_name = arg
            elif arg.strip() == '-c':
                # aggregate and convert only, don't tokenise or kwic
                # TODO: this should really go into doall.py
                parser.convert_only = True
            else:
                input_str.append(arg)
                for input_paths in cls.get_expanded_paths(arg):
                    input_path_list += glob.glob(input_paths)

        if input_path_list:
            parser.run_custom(input_path_list, output_path)

        if parser.has_xml():
            parser.write_xml(output_path)
            print('written %s' % output_path)
        else:
            if not getattr(cls, 'suppressed_output', False):
                print(
                    'WARNING: Nothing to output, please check the input argument (%s)' %
                    ', '.join(input_str))

        print('done')

    def set_paragraphs(self, paragraphs_string=None):
        ret = []

        if paragraphs_string:
            # edfr20125_00589 in range '589-614'
            for paras in paragraphs_string.strip().split(','):
                paras = paras.split('-')
                if len(paras) < 2:
                    paras[-1] = paras[0]
                ret += range(int(paras[0]), int(paras[-1]) + 1)

        self.paragraphs = ret

        return ret

    def is_para_in_range(self, parentid):
        ret = False

        if not self.paragraphs:
            return True

        if parentid:
            # edfr20125_00589 in range '589-614'
            para = re.findall('\d+$', parentid)
            if para:
                ret = int(para[0]) in self.paragraphs

        return ret

    @classmethod
    def get_expanded_paths(cls, path):
        # get_expanded_paths
        # e.g. {16,18}X => [16X, 18X]
        # e.g. {16-18}X => [16X, 17X, 18X]
        ret = [path]

        parts = re.findall(ur'^(.*)\{([-\d,]+)\}(.*)$', path)
        if parts:
            parts = parts[0]
            ranges = parts[1].split(',')
            for range in ranges:
                ends = range.split('-')
                if len(ends) == 1:
                    ends.append(ends[0])
                ends = [int(end) for end in ends]
                ends[-1] += 1
                for end in xrange(*ends):
                    ret.append(ur'%s%s%s' % (parts[0], end, parts[-1]))

        return ret

    def set_namespaces_from_unicode(self, xml_string):
        # grab all the namespaces
        self.namespaces = {
            prefix: uri
            for definition, prefix, uri
            in re.findall(ur'(xmlns:?(\w+)?\s*=\s*"([^"]+)")', xml_string)
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
        try:
            self.xml = ET.fromstring(xml_string.encode('utf-8'))
        except Exception as e:
            f = open('error.log', 'w')
            f.write(xml_string.encode('utf-8'))
            f.close()
            raise e

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
        ret = True
        import codecs
        with codecs.open(filepath, 'r', 'utf-8') as f:
            content = f.read()

            content = self.save_xml_comments(content)

            try:
                self.set_xml_from_unicode(content)

                # self.is_wellformed(self.get_unicode_from_xml())

            except ET.ParseError as e:
                print(e)
                ret = False

        return ret

    def forget_xml_comments(self):
        self.xml_comments = []

    def restore_xml_comments(self, content):
        # xml.etree.ElementTree does NOT preserve <!-- -->
        # We could use lxml but that would mean asking project partners
        # to install that... let's do it manually.
        # return content
        def replace_comment(match):
            ret = ur''
            if self.xml_comments:
                ret = self.xml_comments[int(match.group(1))]
            return ret

        return re.sub(ur'(?musi)<comment\s*id\s*=\s*"c-(\d+)"\s*/>',
                      replace_comment, content)

    def save_xml_comments(self, content):
        # xml.etree.ElementTree does NOT preserve <!-- -->
        # We could use lxml but that would mean asking project partners
        # to install that... let's do it manually.
        # TODO: Alternatively
        # https://stackoverflow.com/questions/33573807/faithfully-preserve-comments-in-parsed-xml-python-2-7
        # return content
        first_element_index = (re.search(ur'<\s*\w', content)).start()

        def replace_comment(match):
            ret = match.group(0)

            if match.start() > first_element_index:
                commentid = len(self.xml_comments)
                self.xml_comments.append(ret)

                ret = ur'<comment id="c-%s"/>' % commentid

            return ret

        return re.sub(ur'(?musi)<!--.*?-->', replace_comment, content)

    def write_xml(self, file_path, encoding='utf-8'):
        f = open(file_path, 'wb')
        content = u'<?xml version="1.0" encoding="{}"?>\n'.format(encoding)

        # insert the generated date

        date_generated = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        content += u'<!-- AUTO-GENERATED by {} - {} -->\n'.format(
            self.__class__.__name__,
            date_generated
        )

        #
        content += self.get_unicode_from_xml()

        # insert date in tei headers
        content = re.sub(
            ur'(?musi)(\s+)(<publicationStmt>)(.*?)(</publicationStmt>)',
            ur'\1\2\1    <publisher>King' + "'" +
            ur's Digital Laboratory</publisher>\1    <date>{}</date>\1\4'.format(
                date_generated
            ),
            content
        )

        content = self.restore_xml_comments(content)
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
        except ET.ParseError as e:
            print(u'%s' % e)
            # (3056, 242) = (line, char)
            lines = xml_string.split('\n')
            print(lines[e.position[0] - 1])
            print((' ' * (e.position[1] - 1)) + '^')
            ret = False

        return ret

    def remove_elements(self, filters, condition_function=None):
        # Remove all elements in the xml that match any of the given fitlers.
        # e.g. filters = ['del', 'orig', 'seg[@type="semi-dip"]', 'sic', 'pb']
        # self.remove_elements(filters)
        if condition_function is None:
            def condition_function(parent, element): return True

        for filter in filters:
            c = 0
            matches = re.findall('^([^\[]*)(\[.*\])?', filter)
            tag, condition = matches[0]
            for parent in self.xml.findall(ur'.//*[' + tag + ur']'):
                # slower version that completely removes the elements
                elements = parent.findall(filter)
                if len(elements):
                    previous = None
                    for element in list(parent):
                        if element in elements and condition_function(
                                parent, element):
                            # make sure we keep the tail
                            tail = element.tail
                            parent.remove(element)
                            c += 1
                            if tail:
                                if previous is not None:
                                    previous.tail = (
                                        previous.tail or ur'') + tail
                                else:
                                    parent.text = (
                                        parent.text or ur'') + tail
                        else:
                            previous = element

            print('\t removed %s %s' % (c, filter))
