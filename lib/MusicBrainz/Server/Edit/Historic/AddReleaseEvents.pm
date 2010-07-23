package MusicBrainz::Server::Edit::Historic::AddReleaseEvents;
use Moose;
use MusicBrainz::Server::Constants qw(
    $EDIT_HISTORIC_ADD_RELEASE_EVENTS
);

extends 'MusicBrainz::Server::Edit::Historic::EditReleaseEventsOld';

sub edit_name     { 'Edit release events' }
sub edit_type     { $EDIT_HISTORIC_ADD_RELEASE_EVENTS }
sub historic_type { 49 }

__PACKAGE__->meta->make_immutable;
no Moose;
1;
