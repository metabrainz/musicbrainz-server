#!/usr/bin/python2
# -*- coding: utf-8 -*-
"""Fix strings for translators related to code changes for MBS-5651.

Namely, change:
    Review the {doc|list of packaging types} for help.
    - and -
    Please enter the barcode of the release you are entering, see <a href="{url}">Barcode</a> for more information.
Into:
    Review the <a href="{url}" target="_blank">list of packaging types</a> for help.
    - and -
    Please enter the barcode of the release you are entering, see <a href="{url}" target="_blank">Barcode</a> for more information.
"""

import os

def fix_string_1(old_string):
    """Replaces "{doc|..." with "<a href=..."."""
    try:
        new_string = old_string.split('{doc|')
        new_string = [new_string[0]] + new_string[1].split('}')
        new_string = new_string[0] + r'<a href=\"{url}\" target=\"_blank\">' + \
                     new_string[1] + '</a>' + new_string[2]
        print "... Replacing {old_string} with {new_string}.".format(**{
            'old_string': repr(old_string),
            'new_string': repr(new_string),
        })
    except IndexError:
        new_string = old_string
        print "... Nothing to replace in {string}.".format(**{
            'string': old_string,
        })
    return new_string

def fix_string_2(old_string):
    """Adds target="_blank" after href="{url}"."""
    new_string = old_string.replace(r'href=\"{url}\"',
                                    r'href=\"{url}\" target=\"_blank\"')
    print "... Replacing {old_string} with {new_string}.".format(**{
        'old_string': repr(old_string),
        'new_string': repr(new_string),
    })
    return new_string

def handle_file(pofile):
    """PO-file in, altered PO-file out."""

    lines = []
    check_string_1 = r'{doc|list of packaging types}'
    check_string_2a = r'Please enter the barcode of the release you are entering, see <a '
    check_string_2b = r'href=\"{url}\">Barcode</a> for more information.'

    with open(pofile, 'r') as f:
        for line in f:
            if line[:5] == 'msgid' and check_string_1 in line:
                msgid = fix_string_1(line)
                msgstr = fix_string_1(f.next())
                lines = lines + [msgid] + [msgstr]
            # Check whether the msgid is split over several lines.
            elif r'msgid ""' in line:
                lines = lines + [line]
                line = f.next()
                if check_string_2a in line:
                    lines = lines + [line]
                    line = f.next()
                    if check_string_2b in line:
                        msgid = fix_string_2(line)
                        msgstr = fix_string_2(f.next())
                        lines = lines + [msgid] + [msgstr]
                else:
                    lines = lines + [line]
            else:
                lines = lines + [line]
    with open(pofile, 'w') as f:
        print "Writing new {filename}.".format(**{'filename': pofile})
        f.writelines(lines)

def main():
    """Core script logic."""
    for pofile in os.listdir(os.curdir):
        if pofile[:10] == 'mb_server.' and pofile[-3:] == '.po':
            print "Opening {filename}.".format(**{'filename': pofile})
            handle_file(pofile)

if __name__ == '__main__':
    print os.path.abspath('.')
    main()
