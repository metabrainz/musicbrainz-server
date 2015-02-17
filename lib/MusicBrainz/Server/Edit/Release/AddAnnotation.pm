package MusicBrainz::Server::Edit::Release::AddAnnotation;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_ADD_ANNOTATION );
use MusicBrainz::Server::Translation qw( N_l );

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::Release::RelatedEntities';

with 'MusicBrainz::Server::Edit::Annotation::Edit' => {
    model => 'Release',
    edit_name => N_l('Add release annotation'),
    edit_type => $EDIT_RELEASE_ADD_ANNOTATION,
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;
