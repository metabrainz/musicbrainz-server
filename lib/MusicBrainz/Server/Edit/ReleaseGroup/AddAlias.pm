package MusicBrainz::Server::Edit::ReleaseGroup::AddAlias;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_RELEASEGROUP_ADD_ALIAS );
use MusicBrainz::Server::Translation qw( N_lp );

extends 'MusicBrainz::Server::Edit';

with 'MusicBrainz::Server::Edit::Alias::Add' => {
    model => 'ReleaseGroup',
    edit_name => N_lp('Add release group alias', 'edit type'),
    edit_type => $EDIT_RELEASEGROUP_ADD_ALIAS,
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;
