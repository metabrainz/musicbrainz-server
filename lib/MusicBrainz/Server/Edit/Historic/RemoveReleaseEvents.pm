package MusicBrainz::Server::Edit::Historic::RemoveReleaseEvents;
use Moose;
use namespace::autoclean;

use MusicBrainz::Server::Constants qw(
    $EDIT_HISTORIC_REMOVE_RELEASE_EVENTS
);
use MusicBrainz::Server::Translation qw( N_l );

extends 'MusicBrainz::Server::Edit::Historic::EditReleaseEventsOld';

sub edit_name     { N_l('Remove release events (historic)') }
sub edit_kind     { 'remove' }
sub edit_type     { $EDIT_HISTORIC_REMOVE_RELEASE_EVENTS }
sub historic_type { 51 }

1;
