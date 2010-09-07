package MusicBrainz::Server::Edit::Historic::RemoveReleaseEvents;
use Moose;
use MusicBrainz::Server::Constants qw(
    $EDIT_HISTORIC_REMOVE_RELEASE_EVENTS
);

extends 'MusicBrainz::Server::Edit::Historic::EditReleaseEventsOld';

sub edit_name     { 'Edit release events' }
sub edit_type     { $EDIT_HISTORIC_REMOVE_RELEASE_EVENTS }
sub historic_type { 51 }

no Moose;
__PACKAGE__->meta->make_immutable;

1;
