package MusicBrainz::Server::WebService::2::Representation::XML::ISRCList;
use Moose;

with 'MusicBrainz::Server::WebService::2::Representation::XML::Role::List';

sub element { 'isrc-list' }

1;
