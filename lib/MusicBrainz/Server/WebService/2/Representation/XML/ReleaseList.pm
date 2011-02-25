package MusicBrainz::Server::WebService::2::Representation::XML::ReleaseList;
use Moose;

with 'MusicBrainz::Server::WebService::2::Representation::XML::Serializer';

sub element { 'release-list' }

sub attributes {
    my ($self, $releases) = @_;
    return { count => scalar(@$releases) };
}

sub serialize_inner {
    my ($self, $releases) = @_;
    return map { $self->serialize($_) } @$releases;
}

1;
