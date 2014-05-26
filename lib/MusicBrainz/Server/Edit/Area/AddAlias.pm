package MusicBrainz::Server::Edit::Area::AddAlias;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_AREA_ADD_ALIAS );
use MusicBrainz::Server::Translation qw( N_l );

extends 'MusicBrainz::Server::Edit';

with 'MusicBrainz::Server::Edit::Alias::Add' => {
    model => 'Area',
    edit_name => N_l('Add area alias'),
    edit_type => $EDIT_AREA_ADD_ALIAS,
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;
