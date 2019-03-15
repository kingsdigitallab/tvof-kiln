# -*- coding: utf-8 -*-
import sys
import os
import re
from xml_parser import XMLParser
import xml.etree.ElementTree as ET


class Converter(XMLParser):

    default_output = u'converted.xml'
    patterns = [
        re.compile(ur'\w¡?'),
        re.compile(ur"[\s']")
    ]

    def run_custom(self, input_path_list, output_path):
        script_path = os.path.dirname(__file__)

        pre_out_path = output_path + '.pre.xml'
        for path in input_path_list:
            cmd = 'perl "{}" < "{}" > "{}"'.format(
                os.path.join(script_path, 'convert.perl'),
                path,
                pre_out_path
            )
            print(cmd)
            res = os.system(cmd)

            if res:
                print('ERROR while running the above command')
                exit()

            self.read_xml(pre_out_path)

            self.titalise_names()

    def titalise_names(self):
        '''
        Convert the first letter of every word in the <Xname> elements
        to upper case.

        <placeName>marseille</placeName>
        =>
        <placeName><choice><orig>m</orig><reg>M</reg></choice>arseille
        </placeName>
        '''

        if self.xml is None:
            return

        tags = [
            'name',
            'geogName',
            'placeName',
            'persName',
        ]

        unique_els = {}

        def get_unicode_from_el(el):
            return re.sub(u'[^>]+$', '', self.get_unicode_from_xml(el))

        for tag in tags:
            for el in self.xml.findall('.//' + tag):
                before = get_unicode_from_el(el)
                self.titalise_name_el(el)
                unique_els[before] = get_unicode_from_el(el)

        if 0:
            # for debugging purpose only,
            # show all unique name cases and their conversions
            for el in sorted(unique_els.keys()):
                print(repr(el))
                print(repr(unique_els[el]))

    def titalise_name_el(self, el):
        self._titalise_el(el)

    def _titalise_el(self, el, space_mode=False, parent=None, child_index=0):
        if el.tag.lower() == 'orig':
            return space_mode

        space_mode = self._titalise_el_part(el, space_mode)

        if 1:
            for i, child in enumerate(el):
                space_mode = self._titalise_el(
                    child, space_mode=space_mode, parent=el, child_index=i
                )

        if parent is not None:
            space_mode = self._titalise_el_part(
                el, space_mode, parent, child_index)

        return space_mode

    def _titalise_el_part(self, el, space_mode, parent=None, child_index=0):

        part = 'text' if (parent is None) else 'tail'
        val = getattr(el, part, None)

        if val is not None:
            pos = 0
            while True:
                m = self.patterns[space_mode].search(val, pos)
                if m:
                    pos = m.start(0) + 1
                    if not space_mode:
                        # here we convert the first letter of a word
                        # to upper case

                        space_mode = not space_mode
                        # don't convert if already regularised
                        if el.tag.lower() == 'reg':
                            continue
                        # don't convert if followed by ¡
                        if m.group(0)[-1] == u'¡':
                            val = val[:pos] + val[pos + 1:]
                            setattr(el, part, val)
                            continue
                        # don't convert if already a capital
                        if m.group(0) == m.group(0).upper():
                            continue
                        choice = ET.fromstring(
                            '<choice><orig>{}</orig><reg>{}</reg></choice>'.format(
                                m.group(0), m.group(0).upper()
                            )
                        )
                        choice.tail = val[pos:]
                        if parent is None:
                            # we are converting on el.text
                            el.insert(0, choice)
                            el.text = val[:pos - 1]
                        else:
                            # we are converting on el.tail
                            parent.insert(child_index + 1, choice)
                            el.tail = val[:pos - 1]
                        break
                    else:
                        space_mode = not space_mode
                else:
                    break
        return space_mode

    def test(self):
        '''
        Tester for titalise_name_el().

        cases is made of pair of line (input, expected output).
        '''
        cases = u'''
        <placeName>marseille</placeName>
        <placeName><choice><orig>m</orig><reg>M</reg></choice>arseille</placeName>
        <placeName> marseille</placeName>
        <placeName> <choice><orig>m</orig><reg>M</reg></choice>arseille</placeName>
        <placeName><pc/>marseille</placeName>
        <placeName><pc /><choice><orig>m</orig><reg>M</reg></choice>arseille</placeName>
        <placeName>m¡arseille</placeName>
        <placeName>marseille</placeName>
        <placeName>Babilonie</placeName>
        <placeName>Babilonie</placeName>
        <placeName>sainte                            cite</placeName>
        <placeName><choice><orig>s</orig><reg>S</reg></choice>ainte                            <choice><orig>c</orig><reg>C</reg></choice>ite</placeName>
        <geogName>mers de gresse</geogName>
        <geogName><choice><orig>m</orig><reg>M</reg></choice>ers <choice><orig>d</orig><reg>D</reg></choice>e <choice><orig>g</orig><reg>G</reg></choice>resse</geogName>
        <geogName>m¡ers d¡e gresse</geogName>
        <geogName>mers de <choice><orig>g</orig><reg>G</reg></choice>resse</geogName>
        <name type="building">te[m]ple                                <persName>mart</persName></name>
        <name type="building"><choice><orig>t</orig><reg>T</reg></choice>e[m]ple                                <persName><choice><orig>m</orig><reg>M</reg></choice>art</persName></name>
        <name type="building">t¡e[m]ple                                <persName>mart</persName></name>
        <name type="building">te[m]ple                                <persName><choice><orig>m</orig><reg>M</reg></choice>art</persName></name>
        <placeName><choice><orig>v</orig><reg>U</reg></choice>ticam</placeName>
        <placeName><choice><orig>v</orig><reg>U</reg></choice>ticam</placeName>
        <placeName><choice><orig>v</orig><reg>u</reg></choice>ticam</placeName>
        <placeName><choice><orig>v</orig><reg>u</reg></choice>ticam</placeName>
        <placeName>a<mod><add hand="E" place="inline">ufriq[ue]</add><del>[...]</del></mod></placeName>
        <placeName><choice><orig>a</orig><reg>A</reg></choice><mod><add hand="E" place="inline">ufriq[ue]</add><del>[...]</del></mod></placeName>
        <placeName>acha<choice><orig>i</orig><reg>j</reg></choice>e</placeName>
        <placeName><choice><orig>a</orig><reg>A</reg></choice>cha<choice><orig>i</orig><reg>j</reg></choice>e</placeName>
        <placeName>assie<comment id="c-1212" /></placeName>
        <placeName><choice><orig>a</orig><reg>A</reg></choice>ssie<comment id="c-1212" /></placeName>
        <placeName>cartage la                        <choice><seg type="semi-dip">n</seg><seg subtype="toUpper" type="crit">n</seg></choice>o<choice><orig>u</orig><reg>v</reg></choice>ele</placeName>
        <placeName><choice><orig>c</orig><reg>C</reg></choice>artage <choice><orig>l</orig><reg>L</reg></choice>a                        <choice><seg type="semi-dip"><choice><orig>n</orig><reg>N</reg></choice></seg><seg subtype="toUpper" type="crit">n</seg></choice>o<choice><orig>u</orig><reg>v</reg></choice>ele</placeName>
        <placeName>i[e]hr[usa]l[e]m</placeName>
        <placeName><choice><orig>i</orig><reg>I</reg></choice>[e]hr[usa]l[e]m</placeName>
        <placeName>sains iohans de salogres</placeName>
        <placeName><choice><orig>s</orig><reg>S</reg></choice>ains <choice><orig>i</orig><reg>I</reg></choice>ohans <choice><orig>d</orig><reg>D</reg></choice>e <choice><orig>s</orig><reg>S</reg></choice>alogres</placeName>
        <geogName type="sea">la mer de                <placeName>gresse</placeName></geogName>
        <geogName type="sea"><choice><orig>l</orig><reg>L</reg></choice>a <choice><orig>m</orig><reg>M</reg></choice>er <choice><orig>d</orig><reg>D</reg></choice>e                <placeName><choice><orig>g</orig><reg>G</reg></choice>resse</placeName></geogName>
        <geogName><c rend="R">G</c>yon</geogName>
        <geogName><c rend="R">G</c>yon</geogName>
        <persName><choice><orig>i</orig><reg>J</reg></choice>ehan l¡<choice><orig /><reg>'</reg></choice>ircanien</persName>
        <persName><choice><orig>i</orig><reg>J</reg></choice>ehan l<choice><orig /><reg>'</reg></choice><choice><orig>i</orig><reg>I</reg></choice>rcanien</persName>        '''
        cases = cases.split('\n')
        while cases:
            input = cases.pop(0).strip()
            if not input:
                continue
            expected = cases.pop(0).strip()

            input_xml = ET.fromstring(input.encode('utf-8'))
            self.titalise_name_el(input_xml)
            output = self.get_unicode_from_xml(input_xml)
            if expected != output:
                print('TEST FAILED:')
                print(u'  input   : ' + input)
                print(u'  output  : ' + output)
                print(u'  expected: ' + expected)

        print('Tested')


if 1:
    Converter.run()
else:
    Converter().test()
