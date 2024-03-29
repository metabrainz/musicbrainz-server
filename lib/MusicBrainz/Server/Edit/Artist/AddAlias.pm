package MusicBrainz::Server::Edit::Artist::AddAlias;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_ARTIST_ADD_ALIAS );
use MusicBrainz::Server::Translation qw( N_lp );

extends 'MusicBrainz::Server::Edit';

with 'MusicBrainz::Server::Edit::Alias::Add' => {
    model => 'Artist',
    edit_name => N_lp('Add artist alias', 'edit type'),
    edit_type => $EDIT_ARTIST_ADD_ALIAS,
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;
