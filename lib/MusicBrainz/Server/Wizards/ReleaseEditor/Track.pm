package MusicBrainz::Server::Wizards::ReleaseEditor::Track;
use Moose;
use MooseX::Storage;

with Storage;

has 'name' => (
    isa => 'Str',
    is  => 'rw',
);

has 'id' => (
    isa => 'Int',
    is  => 'rw',
);

has 'artist' => (
    isa => 'Str',
    is  => 'rw',
);

has 'artist_id' => (
    isa => 'Int',
    is  => 'rw',
    predicate => 'confirmed',
    clearer => 'clear_artist_id',
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

before 'artist' => sub
{
    my $self = shift;

    if (@_)
    {
        my $new_name = shift;
        $self->clear_artist_id
            if $new_name ne $self->artist;
    }
};

sub to_track
{
    my $self = shift;

    return MusicBrainz::Server::Track->new(
        undef,
        name => $self->name,
        sequence => $self->sequence,
        artist => MusicBrainz::Server::Artist->new(
            undef,
            name => $self->artist,
            id   => $self->artist_id,
        )
    );
}

1;
