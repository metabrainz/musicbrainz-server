package MusicBrainz::Server::Edit::Label::AddAnnotation;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_LABEL_ADD_ANNOTATION );
use MusicBrainz::Server::Translation qw( N_lp );

extends 'MusicBrainz::Server::Edit';

with 'MusicBrainz::Server::Edit::Annotation::Edit' => {
    model => 'Label',
    edit_name => N_lp('Add label annotation', 'edit type'),
    edit_type => $EDIT_LABEL_ADD_ANNOTATION,
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;
