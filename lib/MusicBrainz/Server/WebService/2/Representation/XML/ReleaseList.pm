package MusicBrainz::Server::WebService::2::Representation::XML::ReleaseList;
use Moose;

with 'MusicBrainz::Server::WebService::2::Representation::XML::Role::List';

sub element { 'release-list' }

1;
