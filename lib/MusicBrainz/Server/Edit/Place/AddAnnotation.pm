package MusicBrainz::Server::Edit::Place::AddAnnotation;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_PLACE_ADD_ANNOTATION );
use MusicBrainz::Server::Translation qw( N_lp );

extends 'MusicBrainz::Server::Edit';

with 'MusicBrainz::Server::Edit::Annotation::Edit' => {
    model => 'Place',
    edit_name => N_lp('Add place annotation', 'edit type'),
    edit_type => $EDIT_PLACE_ADD_ANNOTATION,
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;
