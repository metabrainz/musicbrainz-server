#!/usr/bin/env perl

BEGIN { $ENV{CATALYST_ENGINE} ||= 'CGI' }

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use MusicBrainz::Server;

MusicBrainz::Server->run;

1;

=head1 NAME

musicbrainz_server_cgi.pl - Catalyst CGI

=head1 SYNOPSIS

See L<Catalyst::Manual>

=head1 DESCRIPTION

Run a Catalyst application as a cgi script.

=head1 AUTHORS

Catalyst Contributors, see Catalyst.pm

=head1 COPYRIGHT


This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
