package MusicBrainz::Server::Edit::Historic::RemoveReleaseEvents;
use Moose;
use namespace::autoclean;

use MusicBrainz::Server::Constants qw(
    $EDIT_HISTORIC_REMOVE_RELEASE_EVENTS
);
use MusicBrainz::Server::Edit::Constants qw( %EDIT_KIND_LABELS );
use MusicBrainz::Server::Translation qw( N_lp );

extends 'MusicBrainz::Server::Edit::Historic::EditReleaseEventsOld';

sub edit_name     { N_lp('Remove release events (historic)', 'edit type') }
sub edit_kind     { $EDIT_KIND_LABELS{'remove'} }
sub edit_type     { $EDIT_HISTORIC_REMOVE_RELEASE_EVENTS }
sub historic_type { 51 }

1;
