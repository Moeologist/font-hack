import fontTools.ttx as ttx
import afdko.otc2otf
import afdko.otf2otc
import lxml.etree as ET

import sys
import os
import shutil
import os.path as p
from copy import deepcopy
import re
import codecs


_PWD_STACK = []


def pushd(path):
    _PWD_STACK.append(p.abspath(p.curdir))
    os.chdir(path)


def popd():
    os.chdir(_PWD_STACK.pop())


def names(path):
    path = p.abspath(path)
    dirname = p.dirname(path)
    filename = p.basename(path)
    basename, extname = p.splitext(filename)
    return dirname, filename, basename, extname


def convert_uni_cmapfm(element):
    uni_sub = ['3', '0', '1', '2']
    uni_ful = ['4', '6']
    e = deepcopy(element)
    pEID = e.get('platEncID')
    if e.tag != 'cmap_format_4' and e.tag != 'cmap_format_12':
        return None
    if pEID in uni_sub:
        if e.tag == 'cmap_format_12':
            e.set('platEncID', '10')
        else:
            e.set('platEncID', '1')
    elif pEID in uni_ful:
        e.set('platEncID', '10')
    else:
        return None
    e.set('platformID', '3')
    return e


def convert_win_ful2bmp(element):
    if element.tag != 'cmap_format_12' or element.get(
            'platformID') != '3'or element.get('platEncID') != '10':
        return None
    e = ET.Element(
        'cmap_format_4',
        {'platformID': '3', 'platEncID': '1', 'language': '0'}
    )
    e.text = '\n      '
    for i in element:
        if i.tag == 'map':
            code_str = i.get('code')
            assert(i.get('code').startswith('0x'))
            code = int(code_str[2:], 16)
            if code >= 0 and code <= 0xffff:
                mp = deepcopy(i)
                mp.tail = '\n      '
                e.append(mp)
    return e


def process_cmap(element):
    UniPS0 = None
    UniPS1 = None
    UniBMP = None
    UniFul = None
    WinBMP = None
    WinFul = None
    WinSym = None
    CvtBMP = None
    for i in element:
        if i.tag.startswith('cmap_format'):
            if i.get('platformID') == '3' and i.get('platEncID') == '0':
                assert(WinSym is None)
                WinSym = i
            elif i.get('platformID') == '3' and i.get('platEncID') == '1':
                assert(WinBMP is None)
                WinBMP = i
            elif i.get('platformID') == '3' and i.get('platEncID') == '10':
                assert(WinFul is None)
                WinFul = i
            elif i.get('platformID') == '0' and i.get('platEncID') == '0':
                assert(UniPS0 is None)
                UniPS0 = i
            elif i.get('platformID') == '0' and i.get('platEncID') == '1':
                assert(UniPS1 is None)
                UniPS1 = i
            elif i.get('platformID') == '0' and i.get('platEncID') == '3':
                assert(UniBMP is None)
                UniBMP = i
            elif i.get('platformID') == '0' and i.get('platEncID') == '4':
                assert(UniFul is None)
                UniFul = i

    if UniBMP is not None:
        CvtBMP = convert_uni_cmapfm(UniBMP)

    if WinFul is None:
        if UniFul is not None:
            WinFul = convert_uni_cmapfm(UniFul)
        elif CvtBMP is not None and CvtBMP.get('platEncID') == '10':
            WinFul = CvtBMP

    if WinBMP is None:
        if CvtBMP is not None and CvtBMP.get('platEncID') == '1':
            WinBMP = CvtBMP
        elif WinFul is not None:
            WinBMP = convert_win_ful2bmp(WinFul)
        elif UniPS1 is not None:
            WinBMP = convert_uni_cmapfm(UniPS1)
        elif UniPS0 is not None:
            WinBMP = convert_uni_cmapfm(UniPS0)

    if WinFul is not None:
        element.append(WinFul)
    if WinBMP is not None:
        element.append(WinBMP)
    if WinBMP is not None and WinSym is not None:
        element.remove(WinSym)


def convert_mac_namerc(element):
    langIDmap = {
        '0': '0409',
        '1': '040c',
        '2': '0407',
        '3': '0410',
        '4': '0413',
        '5': '041d',
        '6': '0c0a',
        '7': '0406',
        '8': '0816',
        '9': '0414',
        'a': '040d',
        'b': '0411',
        'c': '0401',
        'd': '040b',
        'e': '0408',
        'f': '040f',
        '10': '043a',
        '11': '041f',
        '12': '041a',
        '13': '0404',
        '14': '0420',
        '15': '0439',
        '16': '041e',
        '17': '0412',
        '18': '0427',
        '19': '0415',
        '1a': '040e',
        '1b': '0425',
        '1c': '0426',
        '1d': '243b',
        '1e': '0438',
        '1f': '048c',
        '20': '0419',
        '21': '0804',
        '22': '0813',
        '23': '083c',
        '24': '041c',
        '25': '0418',
        '26': '0405',
        '27': '041b',
        '28': '0424',
        '29': 'Yiddish',
        '2a': '0c1a',
        '2b': '042f',
        '2c': '0402',
        '2d': '0422',
        '2e': '0423',
        '2f': '0843',
        '30': '043f',
        '31': '082c',
        '32': '042c',
        '33': '042b',
        '34': '0437',
        '35': '0418',
        '36': '0440',
        '37': '0428',
        '38': '0442',
        '39': '0850',
        '3a': '0450',
        '3b': '0463',
        '3C': 'Kurdish',
        '3D': 'Kashmiri',
        '3E': 'Sindhi',
        '3f': '0451',
        '40': '0461',
        '41': '044f',
        '42': '044e',
        '43': '0845',
        '44': '044d',
        '45': '0447',
        '46': '0446',
        '47': '0448',
        '48': '044c',
        '49': '044b',
        '4a': '0449',
        '4b': '044a',
        '4c': '045b',
        '4D': 'Burmese',
        '4e': '0453',
        '4f': '0454',
        '50': '042a',
        '51': '0421',
        '52': 'Tagalog',
        '53': '043e',
        '54': '083e',
        '55': '045e',
        '56': 'Tigrinya',
        '57': 'Galla',
        '58': 'Somali',
        '59': '0441',
        '5a': '0487',
        '5B': 'Rundi',
        '5C': 'Nyanja/Chewa',
        '5D': 'Malagasy',
        '5E': 'Esperanto',
        '5f': '0452',
        '60': '042d',
        '61': '0403',
        '62': 'Latin',
        '63': '0c6b',
        '64': 'Guarani',
        '65': 'Aymara',
        '66': '0444',
        '67': '0480',
        '68': 'Dzongkha',
        '69': 'Javanese (Roman script)',
        '6A': 'Sundanese (Roman script)',
        '6b': '0456',
        '6c': '0436',
        '6d': '047e',
        '6e': '045d',
        '6F': 'Scottish Gaelic',
        '70': 'Manx Gaelic',
        '71': 'Irish Gaelic (with dot above)',
        '72': 'Tongan',
        '73': '0408',
        '74': '046f',
        '75': 'Azerbaijani (Roman script)'
    }

    e = deepcopy(element)

    if e.get('unicode') is not None:
        e.attrib.pop('unicode')

    mac_id = e.get('langID')
    assert(mac_id.startswith('0x'))

    win_id_num = langIDmap.get(mac_id[2:].lower())
    if win_id_num is None or not re.match(r'[0-9a-fA-F]+', win_id_num):
        return None
    win_id_num = win_id_num.lower()
    if win_id_num.startswith('0'):
        win_id_num = win_id_num[1:]
    win_id = '{}{}'.format('0x', win_id_num)

    e.set('langID', win_id)
    e.set('platformID', '3')
    e.set('platEncID', '1')
    return e


def convert_uni_namerc(element):
    e = deepcopy(element)
    pEID = e.get('platEncID')
    langID = e.get('langID')

    if pEID == '5':
        return None
    elif pEID == '4' or pEID == '6':
        e.set('platEncID', '10')
    else:
        e.set('platEncID', '1')

    if langID == '0x0':
        e.set('langID', '0x409')
    else:
        return None

    e.set('platformID', '3')
    return e


def check_append(et, element):
    exist = False
    for i in et:
        if element.attrib == i.attrib:
            exist = True
            break
    if not exist:
        et.append(element)


def remove_name_prefixdot(element):
    name = element.text.strip('\n').strip(' ')
    if name.startswith('.'):
        element.text = element.text.replace(name, name[1:])


def process_name(element):
    win_record = []
    mac_record = []
    uni_record = []

    for i in element:
        if i.tag == 'namerecord':
            if i.get('platformID') == '3':
                win_record.append(i)
            elif i.get('platformID') == '1':
                mac_record.append(i)
            elif i.get('platformID') == '0':
                uni_record.append(i)

    converted = []
    for i in mac_record:
        cvt = convert_mac_namerc(i)
        if cvt is not None:
            check_append(converted, cvt)
    for i in uni_record:
        cvt = convert_uni_namerc(i)
        if cvt is not None:
            check_append(converted, cvt)

    for i in converted:
        check_append(element, i)


def process_ttx(path):
    tree = ET.parse(path)
    root = tree.getroot()
    for i in root:
        if i.tag == 'cmap':
            process_cmap(i)
        elif i.tag == 'name':
            process_name(i)
    mod = p.join('modified', path)
    with open(mod, mode='w', encoding='utf-8') as m:
        m.write('<?xml version="1.0" encoding="UTF-8"?>\n')
        m.write(
            ET.tostring(
                tree,
                encoding='utf-8',
                pretty_print=True
            ).decode(encoding='utf-8'))


def process_ttf(name):
    dirname, filename, basename, extname = names(name)
    ttxname = basename + '.ttx'

    ttx.main(['-t', 'cmap', '-t', 'name', '-o', ttxname, name])

    if not p.exists('modified'):
        os.makedirs('modified')

    process_ttx(ttxname)
    ttxnew = p.join('modified', ttxname)
    ttx.main(['-d', 'modified', '-b', '-m', name, ttxnew])


def process_ttc(name):
    pwd = os.curdir
    afdko.otc2otf.main([name])
    ttfs = []

    for i in os.scandir():
        if i.is_file():
            if i.name.startswith('.'):
                new_name = i.name.strip('.')
                if p.exists(new_name):
                    os.remove(i.name)

    for i in os.scandir():
        if i.is_file():
            i_base, i_ext = p.splitext(i.name)
            if i_ext == '.otf' or i_ext == '.ttf':
                process_ttf(i.name)
                ttfs.append(i.name)

    if p.exists('modified'):
        args = [p.join('modified', i) for i in ttfs] + \
            ['-o', p.join('modified', name)]
        afdko.otf2otc.run(args)


def process_file(path):
    dirname, filename, basename, extname = names(path)
    temp_dir = p.join('Temp', basename)
    done_dir = 'Done'

    if not p.exists(temp_dir):
        os.makedirs(temp_dir)
    else:
        shutil.rmtree(temp_dir, True)
        os.makedirs(temp_dir)

    if not p.exists(done_dir):
        os.makedirs(done_dir)

    done_dir = p.abspath(done_dir)
    pushd(temp_dir)

    shutil.copyfile(p.join(dirname, filename), filename)

    if extname == '.ttc':
        process_ttc(filename)
    elif extname == '.ttf' or extname == '.otf':
        process_ttf(filename)

    shutil.move(p.join('modified', filename), p.join(done_dir, filename))
    popd()


def main():
    assert(len(sys.argv) == 2)
    sys.stdout = codecs.getwriter('utf-8')(sys.stdout.detach())
    process_file(sys.argv[1])


if __name__ == '__main__':
    main()
