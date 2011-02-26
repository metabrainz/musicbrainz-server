package MusicBrainz::Server::WebService::2::Representation::XML::Release;
use Moose;

with map {
    "MusicBrainz::Server::WebService::2::Representation::XML::Role::$_"
} qw (
    GID
    ArtistCredit
    Name
    SortName
    Comment
);

sub element { 'release' }

1;
