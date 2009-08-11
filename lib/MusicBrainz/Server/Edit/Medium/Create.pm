package MusicBrainz::Server::Edit::Medium::Create;
use Moose;

use Moose::Util::TypeConstraints;
use MooseX::Types::Moose qw( Str Int );
use MooseX::Types::Structured qw( Dict Optional );
use MusicBrainz::Server::Constants qw( $EDIT_MEDIUM_CREATE );
use MusicBrainz::Server::Data::Medium;
use MusicBrainz::Server::Data::Utils qw( defined_hash );

extends 'MusicBrainz::Server::Edit';

sub edit_type { $EDIT_MEDIUM_CREATE }
sub edit_name { "Create Medium" }
sub entity_model { 'Medium' }
sub entity_id { shift->medium_id }

has 'medium_id' => (
    isa => 'Int',
    is  => 'rw'
);

has 'medium' => (
    isa => 'Medium',
    is => 'rw'
);

has '+data' => (
    isa => Dict[
        name => Optional[Str],
        format_id => Optional[Int],
        position => Int,
        release_id => Int,
        tracklist_id => Int,
    ]
);

sub insert
{
    my $self = shift;
    my $medium = $self->c->model('Medium')->insert( $self->data );

    $self->medium($medium);
    $self->medium_id($medium->id);
}

sub reject
{
    my $self = shift;
    $self->c->model('Medium')->delete($self->medium_id);
}

# medium_id is handled separately, as it should not be copied if the edit is cloned
# (a new different medium_id would be used)
override 'to_hash' => sub
{
    my $self = shift;
    my $hash = super(@_);
    $hash->{medium_id} = $self->medium_id;
    return $hash;
};

before 'restore' => sub
{
    my ($self, $hash) = @_;
    $self->medium_id(delete $hash->{medium_id});
};

__PACKAGE__->meta->make_immutable;
__PACKAGE__->register_type;

no Moose;

1;

