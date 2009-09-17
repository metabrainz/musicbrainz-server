package MusicBrainz::Server::Edit::Recording::AddAnnotation;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_RECORDING_ADD_ANNOTATION );

extends 'MusicBrainz::Server::Edit::Annotation::Edit';

sub edit_name { 'Add recording annotation' }
sub edit_type { $EDIT_RECORDING_ADD_ANNOTATION }

sub related_entities { { recording => [ shift->recording_id ] } }
sub models { [qw( Recording )] }

sub _annotation_model { shift->c->model('Recording')->annotation }

has 'recording_id' => (
    isa => 'Int',
    is => 'rw',
    lazy => 1,
    default => sub { shift->data->{entity_id} }
);

has 'recording' => (
    isa => 'Recording',
    is => 'rw',
);

__PACKAGE__->meta->make_immutable;
no Moose;

1;
