package MusicBrainz::Server::Wizards::ReleaseEditor::ConfirmedArtist;
use Moose::Role;

use MusicBrainz::Server::Artist;

has 'artist' => (
    is => 'rw',
    required => 1,
);

has 'artist_id' => (
    is => 'rw',
    clearer => 'clear_artist_id',
    predicate => 'confirmed_artist',
);

before 'artist' => sub
{
    my ($self,  $new_name) = @_;

    $self->clear_artist_id, warn !$self->confirmed_artist, warn $self
        if (defined $new_name && $new_name ne $self->artist);
};

sub artist_model
{
    my $self = shift;
    return MusicBrainz::Server::Artist->new(undef,
        name => $self->artist,
        id   => $self->artist_id,
    );
}

1;