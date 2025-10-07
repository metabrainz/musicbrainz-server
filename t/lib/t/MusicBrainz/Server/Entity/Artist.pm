package t::MusicBrainz::Server::Entity::Artist;
use strict;
use warnings;

use Test::Routine;
use Test::Moose;
use Test::More;

use Hook::LexWrap;
use MusicBrainz::Server::Entity::Artist;
use MusicBrainz::Server::Entity::ArtistType;
use MusicBrainz::Server::Entity::ArtistAlias;

use MusicBrainz::Server::Constants qw(
    $DARTIST_ID
    $VARTIST_ID
    $VARTIST_GID
    $ANON_ARTIST_GID
    $ANON_ARTIST_ID
    $DATA_ARTIST_GID
    $DATA_ARTIST_ID
    $DIALOGUE_ARTIST_GID
    $DIALOGUE_ARTIST_ID
    $NO_ARTIST_GID
    $NO_ARTIST_ID
    $TRAD_ARTIST_GID
    $TRAD_ARTIST_ID
    $UNKNOWN_ARTIST_GID
    $UNKNOWN_ARTIST_ID
);

test 'Check is_special_purpose' => sub {
    ok(
        MusicBrainz::Server::Entity::Artist->new( id => $DARTIST_ID )->is_special_purpose,
        'The id for Deleted Artist is detected as a special purpose artist ID',
    );
    ok(
        MusicBrainz::Server::Entity::Artist->new( id => $VARTIST_ID )->is_special_purpose,
        'The id for Deleted Artist is detected as a special purpose artist ID',
    );
    ok(
        MusicBrainz::Server::Entity::Artist->new( gid => $VARTIST_GID )->is_special_purpose,
        'The MBID for Various Artists is detected as a special purpose artist MBID',
    );
    ok(
        MusicBrainz::Server::Entity::Artist->new( id => $ANON_ARTIST_ID )->is_special_purpose,
        'The id for [anonymous] is detected as a special purpose artist ID',
    );
    ok(
        MusicBrainz::Server::Entity::Artist->new( gid => $ANON_ARTIST_GID )->is_special_purpose,
        'The MBID for [anonymous] is detected as a special purpose artist MBID',
    );
    ok(
        MusicBrainz::Server::Entity::Artist->new( id => $DATA_ARTIST_ID )->is_special_purpose,
        'The id for [data] is detected as a special purpose artist ID',
    );
    ok(
        MusicBrainz::Server::Entity::Artist->new( gid => $DATA_ARTIST_GID )->is_special_purpose,
        'The MBID for [data] is detected as a special purpose artist MBID',
    );
    ok(
        MusicBrainz::Server::Entity::Artist->new( id => $DIALOGUE_ARTIST_ID )->is_special_purpose,
        'The id for [dialogue] is detected as a special purpose artist ID',
    );
    ok(
        MusicBrainz::Server::Entity::Artist->new( gid => $DIALOGUE_ARTIST_GID )->is_special_purpose,
        'The MBID for [dialogue] is detected as a special purpose artist MBID',
    );
    ok(
        MusicBrainz::Server::Entity::Artist->new( id => $NO_ARTIST_ID )->is_special_purpose,
        'The id for [no artist] is detected as a special purpose artist ID',
    );
    ok(
        MusicBrainz::Server::Entity::Artist->new( gid => $NO_ARTIST_GID )->is_special_purpose,
        'The MBID for [no artist] is detected as a special purpose artist MBID',
    );
    ok(
        MusicBrainz::Server::Entity::Artist->new( id => $TRAD_ARTIST_ID )->is_special_purpose,
        'The id for [traditional] is detected as a special purpose artist ID',
    );
    ok(
        MusicBrainz::Server::Entity::Artist->new( gid => $TRAD_ARTIST_GID )->is_special_purpose,
        'The MBID for [traditional] is detected as a special purpose artist MBID',
    );
    ok(
        MusicBrainz::Server::Entity::Artist->new( id => $UNKNOWN_ARTIST_ID )->is_special_purpose,
        'The id for [unknown] is detected as a special purpose artist ID',
    );
    ok(
        MusicBrainz::Server::Entity::Artist->new( gid => $UNKNOWN_ARTIST_GID )->is_special_purpose,
        'The MBID for [unknown] is detected as a special purpose artist MBID',
    );
    ok(
        !MusicBrainz::Server::Entity::Artist->new( id => 5 )->is_special_purpose,
        'A random artist id is not detected as special purpose',
    );
    ok(
        !MusicBrainz::Server::Entity::Artist->new( gid => '7527f6c2-d762-4b88-b5e2-9244f1e34c46' )->is_special_purpose,
        'A random artist MBID is not detected as special purpose',
    );
};

test all => sub {

my $artist = MusicBrainz::Server::Entity::Artist->new();
ok( defined $artist->begin_date );
ok( $artist->begin_date->is_empty );
ok( defined $artist->end_date );
ok( $artist->end_date->is_empty );

is( $artist->type_name, undef );
is( $artist->last_updated , undef );
$artist->type(MusicBrainz::Server::Entity::ArtistType->new(id => 1, name => 'Person'));
is( $artist->type_name, 'Person' );
is( $artist->type->id, 1 );
is( $artist->type->name, 'Person' );

$artist->edits_pending(2);
is( $artist->edits_pending, 2 );

};

1;
