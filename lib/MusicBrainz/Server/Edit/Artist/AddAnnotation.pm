package MusicBrainz::Server::Edit::Artist::AddAnnotation;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_ARTIST_ADD_ANNOTATION );
use MusicBrainz::Server::Translation qw ( N_l );

use aliased 'MusicBrainz::Server::Entity::Artist';

extends 'MusicBrainz::Server::Edit::Annotation::Edit';
with 'MusicBrainz::Server::Edit::Artist';

sub edit_name { N_l('Add artist annotation') }
sub edit_kind { 'add' }
sub edit_type { $EDIT_ARTIST_ADD_ANNOTATION }

sub _build_related_entities { { artist => [ shift->artist_id ] } }
sub models { [qw( Artist )] }

sub _annotation_model { shift->c->model('Artist')->annotation }

has 'artist_id' => (
    isa => 'Int',
    is => 'rw',
    lazy => 1,
    default => sub { shift->data->{entity}{id} }
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
    $data->{artist} = $loaded->{Artist}->{ $self->artist_id }
        || Artist->new( name => $self->data->{entity}{name} );

    return $data;
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;
