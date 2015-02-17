package MusicBrainz::Server::Edit::Event::AddAlias;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_EVENT_ADD_ALIAS );
use MusicBrainz::Server::Translation qw( N_l );

extends 'MusicBrainz::Server::Edit';

with 'MusicBrainz::Server::Edit::Alias::Add' => {
    model => 'Event',
    edit_name => N_l('Add event alias'),
    edit_type => $EDIT_EVENT_ADD_ALIAS,
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;
