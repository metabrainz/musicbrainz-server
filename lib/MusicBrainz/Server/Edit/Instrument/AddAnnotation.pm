package MusicBrainz::Server::Edit::Instrument::AddAnnotation;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_INSTRUMENT_ADD_ANNOTATION );
use MusicBrainz::Server::Translation qw( N_l );

extends 'MusicBrainz::Server::Edit';

with 'MusicBrainz::Server::Edit::Annotation::Edit' => {
    model => 'Instrument',
    edit_name => N_l('Add instrument annotation'),
    edit_type => $EDIT_INSTRUMENT_ADD_ANNOTATION,
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;
