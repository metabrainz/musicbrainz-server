package MusicBrainz::Server::Edit::ReleaseGroup::AddAnnotation;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_RELEASEGROUP_ADD_ANNOTATION );
use MusicBrainz::Server::Translation qw( N_lp );

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::ReleaseGroup::RelatedEntities',
     'MusicBrainz::Server::Edit::Annotation::Edit' => {
        model => 'ReleaseGroup',
        edit_name => N_lp('Add release group annotation', 'edit name'),
        edit_type => $EDIT_RELEASEGROUP_ADD_ANNOTATION,
     };

__PACKAGE__->meta->make_immutable;
no Moose;

1;
