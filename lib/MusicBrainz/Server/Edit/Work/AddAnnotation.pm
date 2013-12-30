package MusicBrainz::Server::Edit::Work::AddAnnotation;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_WORK_ADD_ANNOTATION );
use MusicBrainz::Server::Translation qw ( N_l );

extends 'MusicBrainz::Server::Edit::Annotation::Edit';
with 'MusicBrainz::Server::Edit::Work::RelatedEntities';
with 'MusicBrainz::Server::Edit::Work';

use aliased 'MusicBrainz::Server::Entity::Work';

sub edit_name { N_l('Add work annotation') }
sub edit_kind { 'add' }
sub edit_type { $EDIT_WORK_ADD_ANNOTATION }
sub models { [qw( Work )] }
sub _annotation_model { shift->c->model('Work')->annotation }

has 'work_id' => (
    isa => 'Int',
    is => 'rw',
    lazy => 1,
    default => sub { shift->data->{entity}{id} }
);

has 'work' => (
    isa => 'Work',
    is => 'rw',
);

sub foreign_keys
{
    my $self = shift;
    return {
        Work => [ $self->work_id ],
    };
}

around 'build_display_data' => sub
{
    my $orig = shift;
    my ($self, $loaded) = @_;

    my $data = $self->$orig();
    $data->{work} = $loaded->{Work}->{ $self->work_id }
        || Work->new( name => $self->data->{entity}{name} );

    return $data;
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;
