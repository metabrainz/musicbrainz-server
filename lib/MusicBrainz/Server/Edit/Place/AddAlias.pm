package MusicBrainz::Server::Edit::Place::AddAlias;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_PLACE_ADD_ALIAS );
use MusicBrainz::Server::Translation qw( N_l );

extends 'MusicBrainz::Server::Edit';

with 'MusicBrainz::Server::Edit::Alias::Add' => {
    model => 'Place',
    edit_name => N_l('Add place alias'),
    edit_type => $EDIT_PLACE_ADD_ALIAS,
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;
