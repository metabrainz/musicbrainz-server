package MusicBrainz::Server::Wizards::ReleaseEditor::Track;
use Moose;
use MooseX::Storage;

with Storage;
with 'MusicBrainz::Server::Wizards::ReleaseEditor::ConfirmedArtist';

has 'name' => (
    isa => 'Str',
    is  => 'rw',
);

has 'id' => (
    isa => 'Int',
    is  => 'rw',
    clearer => 'clear_id',
    predicate => 'has_id',
);

has 'sequence' => (
    isa => 'Int',
    is  => 'rw',
);

has 'duration' => ( is => 'rw' );

has 'removed' => (
    isa => 'Bool',
    is  => 'rw'
);

sub to_track
{
    my $self = shift;

    return MusicBrainz::Server::Track->new(
        undef,
        name => $self->name,
        sequence => $self->sequence,
        length => $self->duration,
        artist => $self->artist_model,
    );
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;