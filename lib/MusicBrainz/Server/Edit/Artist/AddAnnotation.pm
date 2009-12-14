package MusicBrainz::Server::Edit::Artist::AddAnnotation;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_ARTIST_ADD_ANNOTATION );

extends 'MusicBrainz::Server::Edit::Annotation::Edit';

sub edit_name { 'Add artist annotation' }
sub edit_type { $EDIT_ARTIST_ADD_ANNOTATION }

sub related_entities { { artist => [ shift->artist_id ] } }
sub models { [qw( Artist )] }

sub _annotation_model { shift->c->model('Artist')->annotation }

has 'artist_id' => (
    isa => 'Int',
    is => 'rw',
    lazy => 1,
    default => sub { shift->data->{entity_id} }
);

has 'artist' => (
    isa => 'Artist',
    is => 'rw',
);

sub foreign_keys
{
    my $self = shift;
    return {
        Artist => [ $self->artist_id ],
    };
}

around 'build_display_data' => sub
{
    my $orig = shift;
    my ($self, $loaded) = @_;

    my $data = $self->$orig();
    $data->{artist} = $loaded->{Artist}->{ $self->artist_id };

    return $data;
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;
