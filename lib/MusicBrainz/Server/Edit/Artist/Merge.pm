package MusicBrainz::Server::Edit::Artist::Merge;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_ARTIST_MERGE );

extends 'MusicBrainz::Server::Edit::Generic::Merge';

sub edit_type { $EDIT_ARTIST_MERGE }
sub edit_name { "Merge artists" }

sub _merge_model { 'Artist' }

__PACKAGE__->meta->make_immutable;
no Moose;

1;
