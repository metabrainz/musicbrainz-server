#!/bin/sh

# Run the sanity check script
cd /var/website/musicbrainz/mb_server/admin/cleanup
nice ./SanityCheck.pl -f > /tmp/report.txt
cd /var/website/musicbrainz
nice ./greplog.pl /bfd/log/musicbrainz_error_log >> /tmp/report.txt
mail -s "Daily sanity report" rob@eorbit.net < /tmp/report.txt
rm /tmp/report.txt
