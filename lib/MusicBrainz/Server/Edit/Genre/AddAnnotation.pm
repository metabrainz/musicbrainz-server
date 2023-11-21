package MusicBrainz::Server::Edit::Genre::AddAnnotation;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_GENRE_ADD_ANNOTATION );
use MusicBrainz::Server::Translation qw( N_lp );

extends 'MusicBrainz::Server::Edit';

with 'MusicBrainz::Server::Edit::Annotation::Edit' => {
    model => 'Genre',
    edit_name => N_lp('Add genre annotation', 'edit type'),
    edit_type => $EDIT_GENRE_ADD_ANNOTATION,
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;
