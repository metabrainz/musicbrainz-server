package MusicBrainz::Server::Edit::Recording::AddAnnotation;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_RECORDING_ADD_ANNOTATION );
use MusicBrainz::Server::Translation qw ( N_l );

use aliased 'MusicBrainz::Server::Entity::Recording';

extends 'MusicBrainz::Server::Edit::Annotation::Edit';
with 'MusicBrainz::Server::Edit::Recording';

sub edit_name { N_l('Add recording annotation') }
sub edit_kind { 'add' }
sub edit_type { $EDIT_RECORDING_ADD_ANNOTATION }

sub models { [qw( Recording )] }

sub _annotation_model { shift->c->model('Recording')->annotation }

has 'recording_id' => (
    isa => 'Int',
    is => 'rw',
    lazy => 1,
    default => sub { shift->data->{entity}{id} }
);

with 'MusicBrainz::Server::Edit::Recording::RelatedEntities';

has 'recording' => (
    isa => 'Recording',
    is => 'rw',
);

sub foreign_keys
{
    my $self = shift;
    return {
        Recording => [ $self->recording_id ],
    };
}

around 'build_display_data' => sub
{
    my $orig = shift;
    my ($self, $loaded) = @_;

    my $data = $self->$orig();
    $data->{recording} = $loaded->{Recording}->{ $self->recording_id }
        || Recording->new( name => $self->data->{entity}{name} );

    return $data;
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;
