package MusicBrainz::Server::Edit::Instrument::AddAlias;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_INSTRUMENT_ADD_ALIAS );
use MusicBrainz::Server::Translation qw( N_l );

extends 'MusicBrainz::Server::Edit';

with 'MusicBrainz::Server::Edit::Alias::Add' => {
    model => 'Instrument',
    edit_name => N_l('Add instrument alias'),
    edit_type => $EDIT_INSTRUMENT_ADD_ALIAS
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;
