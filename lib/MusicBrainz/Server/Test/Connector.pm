package MusicBrainz::Server::Test::Connector;
use Moose;
use aliased 'MusicBrainz::Server::DatabaseConnectionFactory' => 'Databases';
use 5.10.0;

extends 'MusicBrainz::Server::Connector';

# No-op. In testing we need the connection to be set up by the test harness,
# and remain over a web request (to share the same transaction).
# t/lib/t/Context.pm manually refreshes connections.
override refresh => sub { };
override disconnect => sub { };

__PACKAGE__->meta->make_immutable;
no Moose;

1;
