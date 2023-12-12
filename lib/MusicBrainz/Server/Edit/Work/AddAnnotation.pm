package MusicBrainz::Server::Edit::Work::AddAnnotation;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_WORK_ADD_ANNOTATION );
use MusicBrainz::Server::Translation qw( N_lp );

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::Work::RelatedEntities',
     'MusicBrainz::Server::Edit::Annotation::Edit' => {
        model => 'Work',
        edit_name => N_lp('Add work annotation', 'edit type'),
        edit_type => $EDIT_WORK_ADD_ANNOTATION,
     };

__PACKAGE__->meta->make_immutable;
no Moose;

1;
