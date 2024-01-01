package MusicBrainz::Server::Edit::Series;
use Moose::Role;
use namespace::autoclean;

use MusicBrainz::Server::Translation qw( lp );

sub edit_category { lp('Series', 'singular') }

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
