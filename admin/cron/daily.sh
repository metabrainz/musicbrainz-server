#!/bin/sh

# Dump the data
cd /var/website/musicbrainz/mb_server/admin
nice ./MBDump.pl /tmp/mbdump.tar.bz2
mv /tmp/mbdump.tar.bz2 /bfd/ftp/pub/musicbrainz

# Dump the RDF data
cd /var/website/musicbrainz/mb_server/admin
nice ./RDFDump.pl /tmp/mbdump.rdf.bz2
mv /tmp/mbdump.rdf.bz2 /bfd/ftp/pub/musicbrainz

# Create the reports
cd /var/website/musicbrainz/mb_server/admin
nice ./Caps.pl > /var/website/musicbrainz/htdocs/reports/caps.html
nice ./BadEntries.pl > /var/website/musicbrainz/htdocs/reports/bad_entries.html
nice ./Unknown.pl > /var/website/musicbrainz/htdocs/reports/unknown.html
