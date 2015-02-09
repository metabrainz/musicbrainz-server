package MusicBrainz::Server::Edit::Release::AddAlias;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_ADD_ALIAS );
use MusicBrainz::Server::Translation qw( N_l );

extends 'MusicBrainz::Server::Edit';

with 'MusicBrainz::Server::Edit::Alias::Add' => {
    model => 'Release',
    edit_name => N_l('Add release alias'),
    edit_type => $EDIT_RELEASE_ADD_ALIAS,
};

sub release_ids {}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
