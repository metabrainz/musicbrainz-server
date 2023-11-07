package MusicBrainz::Server::Edit::Area::AddAnnotation;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_AREA_ADD_ANNOTATION );
use MusicBrainz::Server::Translation qw( N_lp );

extends 'MusicBrainz::Server::Edit';

with 'MusicBrainz::Server::Edit::Annotation::Edit' => {
    model => 'Area',
    edit_name => N_lp('Add area annotation', 'edit name'),
    edit_type => $EDIT_AREA_ADD_ANNOTATION,
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;
