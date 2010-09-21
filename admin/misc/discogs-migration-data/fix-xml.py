import re
import sys
import os

def replace_control_char(match):
    return '&#x%04X;' % ord(match.group(1))

control_char_re = re.compile(r'([\x01-\x08|\x0B|\x0C|\x0E-\x1F])')

sys.stdout.write('<?xml version="1.0" encoding="UTF-8"?>\n')
sys.stdout.write('<releases>\n')
for line in sys.stdin:
    #line = control_char_re.sub(replace_control_char, line)
    line = control_char_re.sub('', line)
    sys.stdout.write(line)
sys.stdout.write('</releases>\n')

