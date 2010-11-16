package MusicBrainz::Server::Edit::Historic::EditReleaseEvents;
use Moose;
use MusicBrainz::Server::Constants qw(
    $EDIT_HISTORIC_EDIT_RELEASE_EVENTS
);
use MusicBrainz::Server::Translation qw ( l ln );

extends 'MusicBrainz::Server::Edit::Historic::EditReleaseEventsOld';

sub edit_name     { l('Edit release events') }
sub edit_type     { $EDIT_HISTORIC_EDIT_RELEASE_EVENTS }
sub historic_type { 50 }

no Moose;
__PACKAGE__->meta->make_immutable;

1;
