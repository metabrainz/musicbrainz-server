#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";

use MooseX::Runnable::Run;
run_application 'MusicBrainz::Server::Sitemap::Incremental', @ARGV;

=head1 SYNOPSIS

admin/BuildIncrementalSitemaps.pl: Build incremental sitemaps that contain all
pages whose JSON-LD markup has changed since the overall sitemaps were built
(see: admin/BuildSitemaps.pl).

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
    --worker-count              number of worker processes to use (default: 1)
=cut

=head1 COPYRIGHT

This file is part of MusicBrainz, the open internet music database.
Copyright (C) 2015 MetaBrainz Foundation
Licensed under the GPL version 2, or (at your option) any later version:
http://www.gnu.org/licenses/gpl-2.0.txt

=cut
