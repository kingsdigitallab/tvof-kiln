# -*- coding: utf-8 -*-
import sys
import os
import re
from xml_parser import XMLParser
import xml.etree.ElementTree as ET
from collections import OrderedDict

# runs all the scripts: aggregate, convert, tokenise, kwic
# use -c flag on command line to do only aggregation and conversion


class ParseAll(XMLParser):

    suppressed_output = True
    default_output = u''

    def reset(self):
        ret = super(ParseAll, self).reset()
        self.para_string = ''
        return ret

    def run_custom(self, input_path_list, output_path):

        # aggregate
        print('-' * 20)
        outfiles = [output_path + 'aggregated.xml']
        from aggregate import Aggregator
        options = input_path_list + ['-o', outfiles[-1]]
        Aggregator.run(options)

        # convert shorthands
        print('-' * 20)
        outfiles += [output_path + 'converted.xml']
        from convert import Converter
        options = [outfiles[-2]] + ['-o', outfiles[-1]]
        Converter.run(options)

        # validate conversion
        print('-' * 20)
        from validate import Validator
        options = [outfiles[-1]] + ['-o', output_path + 'validation.log']
        Validator.run(options)

        if self.convert_only:
            return

        # tokenise
        print('-' * 20)
        outfiles += [output_path + 'tokenised.xml']
        from tokenise import TEITokeniser
        options = [outfiles[-2]] + ['-o', outfiles[-1]]
        TEITokeniser.run(options)

        # kwic.xml
        print('-' * 20)
        outfiles += [output_path + 'kwic.xml']
        from kwic import KWICList
        options = [outfiles[-2]] + ['-o', outfiles[-1]]
        if self.para_string:
            options += ['-r', self.para_string]
        KWICList.run(options)

        # kwic.html
        print('-' * 20)
        outfiles += [output_path + 'kwic.html']
        from kwic_html import KwicHtml
        options = [outfiles[-2]] + ['-o', outfiles[-1]]
        KwicHtml.run(options)

    def set_paragraphs(self, para_string):
        self.para_string = para_string
        return super(ParseAll, self).set_paragraphs(para_string)


ParseAll.run()
