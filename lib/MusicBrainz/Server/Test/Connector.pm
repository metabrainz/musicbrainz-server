package MusicBrainz::Server::Test::Connector;
use Moose;

extends 'MusicBrainz::Server::Connector';

sub _schema { 'musicbrainz_test,musicbrainz' }

__PACKAGE__->meta->make_immutable;
no Moose;

1;

