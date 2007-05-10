#!/usr/bin/env python

import glob
import sys
import shutil
import subprocess
import os.path

conf = {}
for line in open(sys.argv[1], 'rt'):
    line = line.strip()
    if line:
        name, value = line.split('=', 1)
        conf.setdefault(name, []).append(value)

curpath = os.path.abspath(os.path.dirname(__file__))
dstpath = os.path.join(curpath, '..', '..', 'htdocs', 'scripts')
srcpath = os.path.join(dstpath, 'src')

lines = []
for src in conf['include']:
    for filename in glob.glob(os.path.join(srcpath, src)):
        print "Reading", filename
        lines.extend(open(filename, 'rt').readlines())
    lines.append("\n")

filename = os.path.join(dstpath, conf['lib'][0])
tmpfilename = filename + '.tmp'
print "Writing", tmpfilename
file = open(tmpfilename, 'wt')
file.writelines(lines)
file.close()

print "Compresing", filename
pipe = subprocess.Popen(
   ['java', '-jar', os.path.join(curpath, 'dojo_rhino.jar'), '-c', tmpfilename],
   stdout=subprocess.PIPE)

file = open(filename, 'wt')
shutil.copyfileobj(pipe.stdout, file)
file.close()

print "Removing", tmpfilename
os.unlink(tmpfilename)
