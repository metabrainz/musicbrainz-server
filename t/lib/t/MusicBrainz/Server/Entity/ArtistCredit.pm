package t::MusicBrainz::Server::Entity::ArtistCredit;
use Test::Routine;
use Test::Moose;
use Test::More;

use MusicBrainz::Server::Entity::ArtistCredit;
use MusicBrainz::Server::Entity::ArtistCreditName;

test all => sub {

my $artist_credit = MusicBrainz::Server::Entity::ArtistCredit->new();
ok( defined $artist_credit );

$artist_credit->add_name(MusicBrainz::Server::Entity::ArtistCreditName->new(name => 'Artist 1', join_phrase => ' & '));
$artist_credit->add_name(MusicBrainz::Server::Entity::ArtistCreditName->new(name => 'Artist 2'));
is( $artist_credit->name, 'Artist 1 & Artist 2' );

$artist_credit->clear_names();
$artist_credit->add_name(MusicBrainz::Server::Entity::ArtistCreditName->new(name => 'Artist 1', join_phrase => ', '));
$artist_credit->add_name(MusicBrainz::Server::Entity::ArtistCreditName->new(name => 'Artist 2', join_phrase => ' and '));
$artist_credit->add_name(MusicBrainz::Server::Entity::ArtistCreditName->new(name => 'Artist 3'));
is( $artist_credit->name, 'Artist 1, Artist 2 and Artist 3' );

};

1;
