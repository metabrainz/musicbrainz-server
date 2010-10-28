package MusicBrainz::Server::Edit::Historic::AddReleaseEvents;
use strict;
use warninsg;

use MusicBrainz::Server::Constants qw(
    $EDIT_HISTORIC_ADD_RELEASE_EVENTS
);

use base 'MusicBrainz::Server::Edit::Historic::EditReleaseEventsOld';

sub edit_name     { 'Edit release events' }
sub edit_type     { $EDIT_HISTORIC_ADD_RELEASE_EVENTS }
sub historic_type { 49 }

1;
