package MusicBrainz::Server::Edit::Event::RemoveEventArt;
use Moose;
use namespace::autoclean;

use MusicBrainz::Server::Constants qw( $EDIT_EVENT_REMOVE_EVENT_ART );
use MusicBrainz::Server::Translation qw( N_lp );

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::Event';

sub edit_kind { 'remove' }
sub edit_name { N_lp('Remove event art', 'singular, edit type') }
sub edit_template { 'RemoveEventArt' }
sub edit_type { $EDIT_EVENT_REMOVE_EVENT_ART }

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2023 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
