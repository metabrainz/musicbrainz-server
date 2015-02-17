package MusicBrainz::Server::Edit::Series::AddAnnotation;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_SERIES_ADD_ANNOTATION );
use MusicBrainz::Server::Translation qw ( N_l );

extends 'MusicBrainz::Server::Edit';

with 'MusicBrainz::Server::Edit::Annotation::Edit' => {
    model => 'Series',
    edit_name => N_l('Add series annotation'),
    edit_type => $EDIT_SERIES_ADD_ANNOTATION,
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;
