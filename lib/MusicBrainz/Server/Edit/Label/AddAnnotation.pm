package MusicBrainz::Server::Edit::Label::AddAnnotation;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_LABEL_ADD_ANNOTATION );
use MusicBrainz::Server::Translation qw( N_l );

extends 'MusicBrainz::Server::Edit';

with 'MusicBrainz::Server::Edit::Annotation::Edit' => {
    model => 'Label',
    edit_name => N_l('Add label annotation'),
    edit_type => $EDIT_LABEL_ADD_ANNOTATION,
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;
