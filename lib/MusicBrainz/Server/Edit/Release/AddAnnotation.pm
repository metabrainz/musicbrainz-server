package MusicBrainz::Server::Edit::Release::AddAnnotation;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_ADD_ANNOTATION );

extends 'MusicBrainz::Server::Edit::Annotation::Edit';

sub edit_name { 'Add release annotation' }
sub edit_type { $EDIT_RELEASE_ADD_ANNOTATION }

sub related_entities { { release => [ shift->release_id ] } }
sub models { [qw( Release )] }

sub _annotation_model { shift->c->model('Release')->annotation }

has 'release_id' => (
    isa => 'Int',
    is => 'rw',
    lazy => 1,
    default => sub { shift->data->{entity_id} }
);

has 'release' => (
    isa => 'Release',
    is => 'rw',
);

__PACKAGE__->register_type;
__PACKAGE__->meta->make_immutable;
no Moose;

1;
