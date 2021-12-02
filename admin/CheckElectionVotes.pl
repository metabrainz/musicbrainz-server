#!/usr/bin/env perl

use warnings;
use strict;

use FindBin;
use lib "$FindBin::Bin/../lib";

use MusicBrainz::Server::Context;

my $c = MusicBrainz::Server::Context->create_script_context();

$c->model('AutoEditorElection')->try_to_close;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 1998 Robert Kaye

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
