package MusicBrainz::Server::Edit::Genre::AddAlias;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_GENRE_ADD_ALIAS );
use MusicBrainz::Server::Translation qw( N_l );

extends 'MusicBrainz::Server::Edit';

with 'MusicBrainz::Server::Edit::Alias::Add' => {
    model => 'Genre',
    edit_name => N_l('Add genre alias'),
    edit_type => $EDIT_GENRE_ADD_ALIAS,
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;
