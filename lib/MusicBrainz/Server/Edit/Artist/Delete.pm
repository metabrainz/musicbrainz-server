package MusicBrainz::Server::Edit::Artist::Delete;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_ARTIST_DELETE );

extends 'MusicBrainz::Server::Edit::Generic::Delete';

sub edit_type { $EDIT_ARTIST_DELETE }
sub edit_name { "Remove artist" }
sub _delete_model { 'Artist' }


__PACKAGE__->meta->make_immutable;
no Moose;

1;
