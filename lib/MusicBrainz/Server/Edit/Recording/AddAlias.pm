package MusicBrainz::Server::Edit::Recording::AddAlias;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_RECORDING_ADD_ALIAS );
use MusicBrainz::Server::Translation qw( N_l );

extends 'MusicBrainz::Server::Edit';

with 'MusicBrainz::Server::Edit::Alias::Add' => {
    model => 'Recording',
    edit_name => N_l('Add recording alias'),
    edit_type => $EDIT_RECORDING_ADD_ALIAS,
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;
