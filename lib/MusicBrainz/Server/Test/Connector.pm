package MusicBrainz::Server::Test::Connector;
use Moose;
use aliased 'MusicBrainz::Server::DatabaseConnectionFactory' => 'Databases';

extends 'MusicBrainz::Server::Connector';

sub _schema { 'musicbrainz_test,' . Databases->get("READWRITE")->schema; }

__PACKAGE__->meta->make_immutable;
no Moose;

1;

