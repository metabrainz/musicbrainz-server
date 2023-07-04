package MusicBrainz::Server::Edit::Historic::EditReleaseEvents;
use Moose;
use namespace::autoclean;

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
