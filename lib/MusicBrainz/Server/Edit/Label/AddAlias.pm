package MusicBrainz::Server::Edit::Label::AddAlias;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_LABEL_ADD_ALIAS );
use MusicBrainz::Server::Translation qw( N_lp );

extends 'MusicBrainz::Server::Edit';

with 'MusicBrainz::Server::Edit::Alias::Add' => {
    model => 'Label',
    edit_name => N_lp('Add label alias', 'edit type'),
    edit_type => $EDIT_LABEL_ADD_ALIAS,
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;
