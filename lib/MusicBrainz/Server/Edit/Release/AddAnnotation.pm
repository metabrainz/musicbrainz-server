package MusicBrainz::Server::Edit::Release::AddAnnotation;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_ADD_ANNOTATION );
use MusicBrainz::Server::Translation qw( N_lp );

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::Release::RelatedEntities',
     'MusicBrainz::Server::Edit::Annotation::Edit' => {
        model => 'Release',
        edit_name => N_lp('Add release annotation', 'edit type'),
        edit_type => $EDIT_RELEASE_ADD_ANNOTATION,
     };

__PACKAGE__->meta->make_immutable;
no Moose;

1;
