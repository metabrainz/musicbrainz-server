package MusicBrainz::Server::Edit::Historic::AddReleaseEvents;
use Moose;
use namespace::autoclean;

use MusicBrainz::Server::Constants qw(
    $EDIT_HISTORIC_ADD_RELEASE_EVENTS
);
use MusicBrainz::Server::Translation qw( N_l );

extends 'MusicBrainz::Server::Edit::Historic::EditReleaseEventsOld';

sub edit_name     { N_l('Add release events (historic)') }
sub edit_kind     { 'add' }
sub edit_type     { $EDIT_HISTORIC_ADD_RELEASE_EVENTS }
sub historic_type { 49 }

1;
