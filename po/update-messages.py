#!/usr/bin/env python

import re
import os

from babel.messages.catalog import Catalog
from babel.messages.pofile import read_po, write_po
from babel.messages.extract import extract_from_dir

method_map = [('**.tt', 'extract-strings:extract_tt')]
dirname = "../root"

project = "musicbrainz_server"
version = "2009XXXX"
keywords = {'l':(1,), 'ln':(1,2)}
options_map = {}

output_file = "mb_server.pot"

def callback(filename, method, options): 
    if method == 'ignore': 
        return 
    filepath = os.path.normpath(os.path.join(dirname, filename)) 
    optstr = '' 
    if options: 
        optstr = ' (%s)' % ', '.join(['%s="%s"' % (k, v) for 
                                      k, v in options.items()]) 
    print ('extracting messages from %s%s' %( filepath, optstr)) 


outfile = open(output_file, 'w')

try: 
    catalog = Catalog(project=project, 
                      version=version, 
                      charset="UTF-8")     
    
    extracted = extract_from_dir(dirname, method_map, options_map, 
                                 keywords=keywords, 
                                 callback=callback)
    
    for filename, lineno, message, comments in extracted: 
        filepath = os.path.normpath(os.path.join(dirname, filename)) 
        catalog.add(message, None, [(filepath, lineno)], 
                    auto_comments=comments) 
            
    print ('writing PO template file to %s' % output_file) 
    write_po(outfile, catalog, sort_by_file = True)
            
finally: 
    outfile.close()
