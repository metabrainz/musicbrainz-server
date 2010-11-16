package MusicBrainz::Server::Edit::Artist::Delete;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_ARTIST_DELETE );
use MusicBrainz::Server::Translation qw ( l ln );

extends 'MusicBrainz::Server::Edit::Generic::Delete';

sub edit_name { l('Remove artist') }
sub edit_type { $EDIT_ARTIST_DELETE }

sub _delete_model { 'Artist' }


__PACKAGE__->meta->make_immutable;
no Moose;

1;
