package MusicBrainz::Server::Edit::Work::AddAnnotation;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_WORK_ADD_ANNOTATION );

extends 'MusicBrainz::Server::Edit::Annotation::Edit';

sub edit_name { 'Add work annotation' }
sub edit_type { $EDIT_WORK_ADD_ANNOTATION }

sub related_entities { { work => [ shift->work_id ] } }
sub models { [qw( Work )] }

sub _annotation_model { shift->c->model('Work')->annotation }

has 'work_id' => (
    isa => 'Int',
    is => 'rw',
    lazy => 1,
    default => sub { shift->data->{entity_id} }
);

has 'work' => (
    isa => 'Work',
    is => 'rw',
);

__PACKAGE__->meta->make_immutable;
no Moose;

1;
