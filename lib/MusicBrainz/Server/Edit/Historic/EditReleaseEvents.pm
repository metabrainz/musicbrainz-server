package MusicBrainz::Server::Edit::Historic::EditReleaseEvents;
use strict;
use warnings;

use MusicBrainz::Server::Constants qw(
    $EDIT_HISTORIC_EDIT_RELEASE_EVENTS
);

use base 'MusicBrainz::Server::Edit::Historic::EditReleaseEventsOld';

sub edit_name     { 'Edit release events' }
sub edit_type     { $EDIT_HISTORIC_EDIT_RELEASE_EVENTS }
sub historic_type { 50 }

1;
