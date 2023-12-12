package MusicBrainz::Server::Edit::Recording::AddAnnotation;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_RECORDING_ADD_ANNOTATION );
use MusicBrainz::Server::Translation qw( N_lp );

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::Recording::RelatedEntities',
     'MusicBrainz::Server::Edit::Annotation::Edit' => {
        model => 'Recording',
        edit_name => N_lp('Add recording annotation', 'edit type'),
        edit_type => $EDIT_RECORDING_ADD_ANNOTATION,
     };

__PACKAGE__->meta->make_immutable;
no Moose;

1;
