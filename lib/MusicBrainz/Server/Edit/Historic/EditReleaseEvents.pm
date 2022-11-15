package MusicBrainz::Server::Edit::Historic::EditReleaseEvents;
use Moose;

use MusicBrainz::Server::Constants qw(
    $EDIT_HISTORIC_EDIT_RELEASE_EVENTS
);
use MusicBrainz::Server::Translation qw( N_l );

extends 'MusicBrainz::Server::Edit::Historic::EditReleaseEventsOld';

sub edit_name     { N_l('Edit release events (historic)') }
sub edit_kind     { 'edit' }
sub edit_type     { $EDIT_HISTORIC_EDIT_RELEASE_EVENTS }
sub historic_type { 50 }

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
