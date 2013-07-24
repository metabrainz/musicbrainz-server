package t::MusicBrainz::Server::Entity::EditorOAuthToken;
use Test::Routine;
use Test::Moose;
use Test::More;

BEGIN { use MusicBrainz::Server::Entity::EditorOAuthToken };

use DateTime;

test all => sub {

my $token = MusicBrainz::Server::Entity::EditorOAuthToken->new(expire_time => DateTime->now->add( hours => 1));
ok(!$token->is_expired, "Token is not expired");

};

1;
