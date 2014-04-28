package MusicBrainz::Server::Edit::Work::AddAlias;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_WORK_ADD_ALIAS );
use MusicBrainz::Server::Translation qw ( N_l );

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::Work::RelatedEntities';

with 'MusicBrainz::Server::Edit::Alias::Add' => {
    model => 'Work',
    edit_name => N_l('Add work alias'),
    edit_type => $EDIT_WORK_ADD_ALIAS,
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;
