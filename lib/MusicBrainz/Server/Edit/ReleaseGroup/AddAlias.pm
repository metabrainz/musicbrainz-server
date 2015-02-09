package MusicBrainz::Server::Edit::ReleaseGroup::AddAlias;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_GROUP_ADD_ALIAS );
use MusicBrainz::Server::Translation qw( N_l );

extends 'MusicBrainz::Server::Edit';

with 'MusicBrainz::Server::Edit::Alias::Add' => {
    model => 'ReleaseGroup',
    edit_name => N_l('Add release group alias'),
    edit_type => $EDIT_RELEASE_GROUP_ADD_ALIAS,
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;
