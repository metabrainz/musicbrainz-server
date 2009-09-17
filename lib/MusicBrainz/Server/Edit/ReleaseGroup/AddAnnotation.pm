package MusicBrainz::Server::Edit::ReleaseGroup::AddAnnotation;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_RELEASEGROUP_ADD_ANNOTATION );

extends 'MusicBrainz::Server::Edit::Annotation::Edit';

sub edit_name { 'Add release_group annotation' }
sub edit_type { $EDIT_RELEASEGROUP_ADD_ANNOTATION }

sub related_entities { { release_group => [ shift->release_group_id ] } }
sub models { [qw( ReleaseGroup )] }

sub _annotation_model { shift->c->model('ReleaseGroup')->annotation }

has 'release_group_id' => (
    isa => 'Int',
    is => 'rw',
    lazy => 1,
    default => sub { shift->data->{entity_id} }
);

has 'release_group' => (
    isa => 'ReleaseGroup',
    is => 'rw',
);

__PACKAGE__->meta->make_immutable;
no Moose;

1;
