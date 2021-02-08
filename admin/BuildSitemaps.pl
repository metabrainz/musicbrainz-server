#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";

use MooseX::Runnable::Run;
run_application 'MusicBrainz::Server::Sitemap::Overall', @ARGV;

=head1 SYNOPSIS

admin/BuildSitemaps.pl: build XML sitemaps/sitemap-indexes to a standard location.

Options:

    --help                      show this help
    --compress                  compress with gzip (default: true)
    --ping                      ping search engines once built (default: false)
    --web-server                web server URL used as a base in sitemap-index
                                files, without trailing slash (default:
                                DBDefs->CANONICAL_SERVER)
    --database                  database to use (default: MAINTENANCE)
    --output-dir                directory to write sitemaps to (default:
                                root/static/sitemaps/)
    --replication-access-uri    URI to request replication packets from
                                (default:
                                https://metabrainz.org/api/musicbrainz)
=cut

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2015 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
