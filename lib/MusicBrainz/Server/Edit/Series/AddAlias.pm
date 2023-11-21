package MusicBrainz::Server::Edit::Series::AddAlias;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_SERIES_ADD_ALIAS );
use MusicBrainz::Server::Translation qw ( N_lp );

extends 'MusicBrainz::Server::Edit';

with 'MusicBrainz::Server::Edit::Alias::Add' => {
    model => 'Series',
    edit_name => N_lp('Add series alias', 'edit type'),
    edit_type => $EDIT_SERIES_ADD_ALIAS,
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;
