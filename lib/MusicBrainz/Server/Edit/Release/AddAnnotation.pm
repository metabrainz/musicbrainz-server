package MusicBrainz::Server::Edit::Release::AddAnnotation;

use Moose;
use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_ADD_ANNOTATION );
use MusicBrainz::Server::Translation qw ( N_l );

use aliased 'MusicBrainz::Server::Entity::Release';

extends 'MusicBrainz::Server::Edit::Annotation::Edit';
with 'MusicBrainz::Server::Edit::Release::RelatedEntities';
with 'MusicBrainz::Server::Edit::Release';

sub edit_name { N_l('Add release annotation') }
sub edit_kind { 'add' }
sub edit_type { $EDIT_RELEASE_ADD_ANNOTATION }

sub models { [qw( Release )] }

sub _annotation_model { shift->c->model('Release')->annotation }

has 'release_id' => (
    isa => 'Int',
    is => 'rw',
    lazy => 1,
    default => sub { shift->data->{entity}{id} }
);

with 'MusicBrainz::Server::Edit::Release::RelatedEntities';

has 'release' => (
    isa => 'Release',
    is => 'rw',
);

sub foreign_keys
{
    my $self = shift;
    if ($self->preview) {
        return { };
    }
    else {
        return {
            Release => [ $self->release_id ],
        };
    }
}

around 'build_display_data' => sub
{
    my $orig = shift;
    my ($self, $loaded) = @_;

    my $data = $self->$orig();
    unless ($self->preview) {
        $data->{release} = $loaded->{Release}->{ $self->release_id }
            || Release->new( name => $self->data->{entity}{name} );
    }

    return $data;
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;
