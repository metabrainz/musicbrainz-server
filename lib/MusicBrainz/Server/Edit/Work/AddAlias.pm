package MusicBrainz::Server::Edit::Work::AddAlias;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_WORK_ADD_ALIAS );
use MusicBrainz::Server::Translation qw( N_lp );

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::Work::RelatedEntities',
     'MusicBrainz::Server::Edit::Alias::Add' => {
        model => 'Work',
        edit_name => N_lp('Add work alias', 'edit name'),
        edit_type => $EDIT_WORK_ADD_ALIAS,
     };

__PACKAGE__->meta->make_immutable;
no Moose;

1;
