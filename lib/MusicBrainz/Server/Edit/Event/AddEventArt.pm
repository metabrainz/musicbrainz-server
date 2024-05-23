package MusicBrainz::Server::Edit::Event::AddEventArt;
use Moose;
use namespace::autoclean;

use MusicBrainz::Server::Constants qw( $EDIT_EVENT_ADD_EVENT_ART );
use MusicBrainz::Server::Translation qw( N_lp );

extends 'MusicBrainz::Server::Edit';

sub edit_kind { 'add' }
sub edit_name { N_lp('Add event art', 'singular, edit type') }
sub edit_template { 'AddEventArt' }
sub edit_type { $EDIT_EVENT_ADD_EVENT_ART }

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2023 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
