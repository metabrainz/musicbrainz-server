package MusicBrainz::Server::Edit::Historic::AddReleaseEvents;
use Moose;
use namespace::autoclean;

use MusicBrainz::Server::Constants qw(
    $EDIT_HISTORIC_ADD_RELEASE_EVENTS
);
use MusicBrainz::Server::Edit::Constants qw( %EDIT_KIND_LABELS );
use MusicBrainz::Server::Translation qw( N_lp );

extends 'MusicBrainz::Server::Edit::Historic::EditReleaseEventsOld';

sub edit_name     { N_lp('Add release events (historic)', 'edit type') }
sub edit_kind     { $EDIT_KIND_LABELS{'add'} }
sub edit_type     { $EDIT_HISTORIC_ADD_RELEASE_EVENTS }
sub historic_type { 49 }

1;
