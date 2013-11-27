package MusicBrainz::Server::Edit::Place::Delete;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_PLACE_DELETE :expire_action :quality );
use MusicBrainz::Server::Translation qw ( N_l );

extends 'MusicBrainz::Server::Edit::Generic::Delete';
with 'MusicBrainz::Server::Edit::Place';

sub edit_name { N_l('Remove place') }
sub edit_type { $EDIT_PLACE_DELETE }

sub _delete_model { 'Place' }

__PACKAGE__->meta->make_immutable;
no Moose;

1;
