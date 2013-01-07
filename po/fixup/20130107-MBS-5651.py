#!/usr/bin/python2
# -*- coding: utf-8 -*-
"""Fix strings for translators related to code changes for MBS-5651.

Namely, change:
    Review the {doc|list of packaging types} for help.
Into:
    Review the <a href="{url}" target="_blank">list of packaging types</a> for help.
"""

import os

def fix_string(old_string):
    """Replaces the old text with the new text."""
    try:
        new_string = old_string.split('{doc|')
        new_string = [new_string[0]] + new_string[1].split('}')
        new_string = new_string[0] + '<a href="{url}" target="_blank">' +\
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

def handle_file(pofile):
    """PO-file in, altered PO-file out."""
    lines = []
    with open(pofile, 'r') as f:
        for line in f:
            if line[:5] == 'msgid' and '{doc|list of packaging types}' in line:
                msgid = fix_string(line)
                msgstr = fix_string(f.next()) 
                lines = lines + [msgid] + [msgstr]
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
