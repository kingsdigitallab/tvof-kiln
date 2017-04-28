# -*- coding: utf-8 -*-
import sys
import os
import re
from xml_parser import XMLParser


class Aggregator(XMLParser):

    default_output = u'aggregated.xml'

    def run_custom(self, input_path_list, output_path):
        input_path_list = sorted(input_path_list, key=lambda p: [
                                 int(n) for n in re.findall(ur'\d+', p)])
        for input_path in input_path_list:
            if os.path.isfile(input_path):
                self.append_tei(input_path)

    def append_tei(self, input_path):
        ret = False

        print(input_path)

        xml_aggregated = self.xml

        if not self.read_xml(input_path):
            print '\tWARNING: file is not valid XML'
        else:
            # get the body content
            body = self.xml.find('.//body')

            if body is None:
                print '\tWARNING: TEI has no <body> element'
            else:
                if xml_aggregated is None:
                    xml_aggregated = self.xml
                else:
                    xml_aggregated.find('.//body').extend(list(body))

                ret = True

        if ret:
            self.xml = xml_aggregated

        return ret


Aggregator.run()
