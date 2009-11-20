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

sub alter_edit_pending { { Medium => [ shift->medium_id ] } }

has 'medium_id' => (
    isa => 'Int',
    is => 'rw',
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

sub foreign_keys
{
    my $self = shift;
    return {
        Release => { $self->data->{release_id} => [ 'ArtistCredit' ] },
        MediumFormat => { $self->data->{format_id} => [] }
    };
}

sub build_display_data
{
    my ($self, $loaded) = @_;
    return {
        name         => $self->data->{name},
        format       => $loaded->{MediumFormat}->{ $self->data->{format_id} },
        position     => $self->data->{position},
        release      => $loaded->{Release}->{ $self->data->{release_id} },
        tracklist_id => $self->data->{tracklist_id},
    };
}

sub insert
{
    my $self = shift;
    my $medium = $self->c->model('Medium')->insert( $self->data );
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

no Moose;

1;

