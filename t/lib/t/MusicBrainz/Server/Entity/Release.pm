package t::MusicBrainz::Server::Entity::Release;
use Test::Routine;
use Test::Moose;
use Test::More;
use utf8;

use MusicBrainz::Server::Entity::Release;
use MusicBrainz::Server::Entity::ReleasePackaging;
use MusicBrainz::Server::Entity::ReleaseStatus;
use MusicBrainz::Server::Entity::Medium;
use MusicBrainz::Server::Entity::MediumFormat;
use MusicBrainz::Server::Entity::Track;
use MusicBrainz::Server::Entity::Recording;
use MusicBrainz::Server::Entity::Artist;
use MusicBrainz::Server::Entity::Relationship;
use MusicBrainz::Server::Entity::Link;
use MusicBrainz::Server::Entity::PartialDate;


test all => sub {

my $release = MusicBrainz::Server::Entity::Release->new();
does_ok( $release, 'MusicBrainz::Server::Entity::Role::Quality' );

$release->edits_pending(2);
is( $release->edits_pending, 2 );

is( $release->status_name, undef );
$release->status(MusicBrainz::Server::Entity::ReleaseStatus->new(id => 1, name => 'Official'));
is( $release->status_name, 'Official', 'Release status is Official' );
is( $release->status->id, 1 );
is( $release->status->name, 'Official', 'Release status is Official' );

is( $release->packaging_name, undef );
$release->packaging(MusicBrainz::Server::Entity::ReleasePackaging->new(id => 1, name => 'Jewel Case'));
is( $release->packaging_name, 'Jewel Case', 'Release packaging is Jewel Case' );
is( $release->packaging->id, 1 );
is( $release->packaging->name, 'Jewel Case', 'Release packaging is Jewel Case' );

ok( @{$release->labels} == 0 );
ok( @{$release->mediums} == 0 );

is( $release->combined_format_name, '' );
is( $release->combined_track_count, '' );

my $medium1 = MusicBrainz::Server::Entity::Medium->new(track_count => 10, position => 1);
$medium1->format(MusicBrainz::Server::Entity::MediumFormat->new(id => 1, name => 'CD'));
$release->add_medium($medium1);
is( $release->combined_format_name, 'CD', 'Release format is CD' );
is( $release->combined_track_count, '10', 'Release has 10 tracks' );

my $medium2 = MusicBrainz::Server::Entity::Medium->new(track_count => 22, position => 2);
$medium2->format(MusicBrainz::Server::Entity::MediumFormat->new(id => 2, name => 'DVD'));
$release->add_medium($medium2);
is( $release->combined_format_name, 'CD + DVD', 'Release format is CD + DVD' );
is( $release->combined_track_count, '10 + 22', 'Release has 10 + 22 tracks' );

my $medium3 = MusicBrainz::Server::Entity::Medium->new(track_count => 10, position => 3);
$medium3->format(MusicBrainz::Server::Entity::MediumFormat->new(id => 1, name => 'CD'));
$release->add_medium($medium3);
is( $release->combined_format_name, '2×CD + DVD', 'Release format is 2xCD + DVD' );
is( $release->combined_track_count, '10 + 22 + 10', 'Release has 10 + 22 + 10 tracks' );

# MBS-6073
my $track;
my $recording;
my $i = 1;
my $j = 1;

for (; $i <= $medium1->track_count; $i++) {
    $track = MusicBrainz::Server::Entity::Track->new(
        id => $i, position => $i, number => $i);
    $track->recording(MusicBrainz::Server::Entity::Recording->new(id => $i));
    $medium1->add_track($track);
}

for (; $j <= $medium2->track_count; $j++) {
    $track = MusicBrainz::Server::Entity::Track->new(
        id => $i + $j, position => $j, number => $j);
    $track->recording(MusicBrainz::Server::Entity::Recording->new(id => $i + $j));
    $medium2->add_track($track);
}

my $link_type = MusicBrainz::Server::Entity::LinkType->new(
    id => 1,
    link_phrase => 'performed by',
    reverse_link_phrase => 'performed',
    entity0_type => 'artist',
    entity1_type => 'recording'
);

my $link = MusicBrainz::Server::Entity::Link->new(
    type => $link_type,
    attributes => [],
    begin_date => MusicBrainz::Server::Entity::PartialDate->new(),
    end_date => MusicBrainz::Server::Entity::PartialDate->new()
);

my $artist = MusicBrainz::Server::Entity::Artist->new(
    id => 1, name => 'Person', sort_name => 'Person');
$recording = $medium1->tracks->[3]->recording;

my $rel1 = MusicBrainz::Server::Entity::Relationship->new(
    direction => $MusicBrainz::Server::Entity::Relationship::DIRECTION_BACKWARD,
    link => $link,
    entity0 => $artist,
    entity1 => $recording
);

$recording->add_relationship($rel1);
$recording = $medium2->tracks->[4]->recording;

my $rel2 = MusicBrainz::Server::Entity::Relationship->new(
    direction => $MusicBrainz::Server::Entity::Relationship::DIRECTION_BACKWARD,
    link => $link,
    entity0 => $artist,
    entity1 => $recording
);

$recording->add_relationship($rel2);

is_deeply($release->combined_track_relationships, {
    artist => [
        {
            phrase => 'performed',
            items => [
                {
                    rel => $rel1,
                    track_count => 2,
                    tracks => '1.4, 2.5'
                }
            ]
        }
    ]
}, 'MBS-6073: Credit ranges use absolute track position');

$release = MusicBrainz::Server::Entity::Release->new(artist_credit_id => 1);
my $medium = MusicBrainz::Server::Entity::Medium->new();
$release->add_medium($medium);
$track = MusicBrainz::Server::Entity::Track->new(artist_credit_id => 1);
$medium->add_track($track);
is( $release->has_multiple_artists, 0, 'Release does not have multiple artists' );
$track = MusicBrainz::Server::Entity::Track->new(artist_credit_id => 2);
$medium->add_track($track);
is( $release->has_multiple_artists, 1, 'Release has multiple artists' );

};

1;
