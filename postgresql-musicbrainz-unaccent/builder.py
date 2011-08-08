#!/usr/bin/env python

import re
import unicodedata
from collections import defaultdict


localmap = {
    "LATIN SMALL LETTER AE":
        ["LATIN SMALL LETTER A", "LATIN SMALL LETTER E"],
    "LATIN CAPITAL LETTER AE":
        ["LATIN CAPITAL LETTER A", "LATIN CAPITAL LETTER E"],
    "LATIN SMALL LIGATURE OE":
        ["LATIN SMALL LETTER O", "LATIN SMALL LETTER E"],
    "LATIN CAPITAL LIGATURE OE":
        ["LATIN CAPITAL LETTER O", "LATIN CAPITAL LETTER E"],
    "LATIN SMALL LIGATURE IJ":
        ["LATIN SMALL LETTER I", "LATIN SMALL LETTER J"],
    "LATIN CAPITAL LIGATURE IJ":
        ["LATIN CAPITAL LETTER I", "LATIN CAPITAL LETTER J"],
    "LATIN SMALL LETTER SHARP S":
        ["LATIN SMALL LETTER S", "LATIN SMALL LETTER S"],
    "LATIN SMALL LETTER DOTLESS I":
        ["LATIN SMALL LETTER I"],
    "LATIN SMALL LETTER DOTLESS J WITH STROKE":
        ["LATIN SMALL LETTER J"],
    # Based on http://picardplugins.googlecode.com/files/converttypographicpunctuation.py
    'DOUBLE PRIME': ['QUOTATION MARK'],
    'PRIME': ['APOSTROPHE'],
    'SINGLE LEFT-POINTING ANGLE QUOTATION MARK': ['LESS-THAN SIGN'],
    'SINGLE RIGHT-POINTING ANGLE QUOTATION MARK': ['GREATER-THAN SIGN'],
    'HORIZONTAL ELLIPSIS': ['FULL STOP', 'FULL STOP', 'FULL STOP'],
    'RIGHT SINGLE QUOTATION MARK': ['APOSTROPHE'],
    'LEFT SINGLE QUOTATION MARK': ['APOSTROPHE'],
    'SINGLE LOW-9 QUOTATION MARK': ['APOSTROPHE'],
    'RIGHT DOUBLE QUOTATION MARK': ['QUOTATION MARK'],
    'LEFT DOUBLE QUOTATION MARK': ['QUOTATION MARK'],
    'DOUBLE LOW-9 QUOTATION MARK': ['QUOTATION MARK'],
    # Based on http://article.gmane.org/gmane.comp.audio.musicbrainz.style/9731
    'HYPHEN': ['HYPHEN-MINUS'],
    'EN DASH': ['HYPHEN-MINUS'],
    'EM DASH': ['HYPHEN-MINUS'],
    'FIGURE DASH': ['HYPHEN-MINUS'],
    'HORIZONTAL BAR': ['HYPHEN-MINUS'],
    'MINUS SIGN': ['HYPHEN-MINUS'],
}


decomposition_table = {}
marks = set()

for code in xrange(0x10000):
    char = unichr(code)
    name = unicodedata.name(char, '')

    decomposition = unicodedata.decomposition(char).split()
    if decomposition:
        if decomposition[0].startswith('<'):
            del decomposition[0]
        if decomposition:
            decomposition_table[code] = [int(c, 16) for c in decomposition]
    elif ' WITH ' in name:
        decomposition_table[code] = None

    category = unicodedata.category(char)
    if category.startswith('M'):
        marks.add(code)


for from_name, to_names in localmap.iteritems():
    from_code = ord(unicodedata.lookup(from_name))
    decomposition = []
    for to_name in to_names:
        to_code = ord(unicodedata.lookup(to_name))
        decomposition.append(to_code)
    decomposition_table[from_code] = decomposition


# Generate compatibility decomposition and strip marks
# (marks == diacritics == accents)
for from_code in sorted(decomposition_table.keys()):
    decomposition = []
    codes = [from_code]

    # Recursively decompose OR strip WITH.* OR strip marks.
    while codes:
        code = codes.pop(0)

        old_decomposition = decomposition_table.get(code)
        if old_decomposition:
            # Decomposition is defined (when None it means we suspect
            # it may exist but we need to guess, cf WITH regexp below).
            codes.extend(old_decomposition)
            continue

        name = unicodedata.name(unichr(code))
        match = re.match(r'(.*?)\s+WITH .*', name)
        if match:
            # Strip part of the name that we decide to interpret
            # as a diacritic indication.
            stripped_name = match.group(1)
            try:
                codes.append(ord(unicodedata.lookup(stripped_name)))
            except KeyError:
                pass
            else:
                continue

        if code not in marks:
            # Just ignore marks (i.e. diacritics)
            decomposition.append(code)

    if decomposition and decomposition[0] != from_code:
        decomposition_table[from_code] = decomposition
    else:
        del decomposition_table[from_code]


def reference(decomposition_table):
    m = 0
    for code_value in xrange(0x10000):
        print "%04X" % (code_value,),
        decomposition = decomposition_table.get(code_value)
        if decomposition:
            print "=>", " ".join("%04X" % (c,) for c in decomposition)
        else:
            print


def source(decomposition_table):

    verbose = False

    best_total_size = 10 * 1024 * 1024 # arbitrary large, larger that UTF16 

    # # Try block sizes ranging from 2^2 (4) to 2^10 (1024).
    for block_shift in xrange(2, 11):
        block_count = 1 << block_shift
        blocks = []
        indexes = []
        duplicate = 0

        # Create all blocks, using the current block size (block_shift)
        # and store them
        block = []
        for code in xrange(0x10001):
            if code > 0 and code % block_count == 0:
                #block = "|".join(" ".join("%04X" % (c,) for c in values))
                index = 0
                for existing_block in blocks:
                    if block == existing_block:
                        indexes.append(index)
                        duplicate += 1
                        break
                    index += 1
                else:
                    indexes.append(index)
                    blocks.append(block)
                block = []
            if code in decomposition_table:
                #print "x", " ".join("%04X" % (c,) for c in decomposition_table[code])
                block.append(decomposition_table[code])
            else:
                #print "?"
                block.append([])

        if verbose:
            print len(blocks), "blocks of", block_count, "entries, factorized", duplicate, "blocks"

        # Calculate, in bytes, the memory space that would be used by the 
        # blocks generated above if they were encoded in C.
        block_size = 0
        for block in blocks:
            block_size += sum(len(v) for v in block) * 2

        # Each block requires a pointer to the block array (4 bytes)
        block_size += len(blocks) * 4

        # Positions of the entries in the block, for each block (2 bytes)
        block_size += block_count * len(blocks) * 2

        index_size = (1 << (16 - block_shift)) * 2
        total_size = block_size + index_size

        if verbose:
            print "\ttotal block size = ", block_size, ", index size = ", index_size
            print "\ttotal size = ", total_size

        if total_size < best_total_size:
            best_total_size = total_size
            best_blocks = blocks;
            best_indexes = indexes
            best_block_shift = block_shift

    block_count = len(best_blocks)
    block_size = 1 << best_block_shift

    indexes_out = []
    for i in range(0, len(best_indexes), 15):
        indexes_out.append(','.join(map(str, best_indexes[i:i+15])))

    positions_out = []
    data1_out = []
    data2_out = []
    for i, block in enumerate(best_blocks):
        position = 0
        index = []
        data = []
        for entry in block:
            index.append(position)
            data.extend(entry)
            position += len(entry)
        index.append(position)
        positions_out.append('{%s}' % ','.join(map(str, index)))
        cc = []
        for c in data:
            if c <= 0xFFFF:
                cc.append("0x%04X" % c)
            else:
                cc.append("0xFFFD")
        data1_out.append('unsigned short unaccent_data_%d[] = {%s};' % (i, ','.join(cc)))
        data2_out.append('unaccent_data_%d' % (i,))


    data_template = '''/* Generated by builder. Do not modify. */
#define UNACCENT_BLOCK_SHIFT %(block_shift)s
#define UNACCENT_BLOCK_MASK ((1 << UNACCENT_BLOCK_SHIFT) - 1)
%(data1)s
unsigned short *unaccent_data[] = {
%(data2)s
};
'''
    source = data_template % dict(
        data1='\n'.join(data1_out),
        data2=',\n'.join(data2_out),
        block_shift=best_block_shift)
    f = open("musicbrainz_unaccent_data.h", "w")
    f.write(source)

    indexes_template = '''
unsigned char unaccent_indexes[] = {
%(indexes)s
};
'''
    source = indexes_template % dict(
        indexes=',\n'.join(indexes_out))
    f.write(source)

    positions_template = '''
unsigned char unaccent_positions[%(y)s][%(x)s] = {
%(positions)s
};
'''
    source = positions_template % dict(
        positions=',\n'.join(positions_out),
        y=len(positions_out),
        x=block_size+1)
    f.write(source)
    f.close()


#reference(decomposition_table)
source(decomposition_table)
