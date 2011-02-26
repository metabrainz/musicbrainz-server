package MusicBrainz::Server::WebService::2::Representation::XML::Artist;
use Moose;

with map {
    "MusicBrainz::Server::WebService::2::Representation::XML::Role::$_"
} qw (
    GID
    Name
    SortName
    Comment
    DatePeriod
);

sub element { 'artist' }

sub serialize_inner {
    my ($self, $artist, %extra) = @_;
    return (
        $self->serialize($artist->gender),
        $self->serialize($artist->country),
    );
}

1;
