use strict;
use warnings;
use Test::More;

use MusicBrainz::Server::Test;
my $c = MusicBrainz::Server::Test->create_test_context;

use aliased 'MusicBrainz::Server::Entity::Link';
use aliased 'MusicBrainz::Server::Entity::LinkType';
use aliased 'MusicBrainz::Server::Entity::Relationship';
use aliased 'MusicBrainz::Server::Entity::Release';
use aliased 'MusicBrainz::Server::Entity::URL';

use LWP::UserAgent;
my $ua = LWP::UserAgent->new;
$ua->env_proxy;

subtest 'Parses valid cover art relationships' => sub {
    my $release = make_release('coverart', 'http://www.archive.org/download/CoverArtsForVariousAlbum/karenkong-mulakan.jpg');

    $c->model('CoverArt')->load($release);
    ok($release->has_cover_art);
    is($release->cover_art->provider->name, 'archive.org');
    is($release->cover_art->image_uri, 'http://www.archive.org/download/CoverArtsForVariousAlbum/karenkong-mulakan.jpg');

    done_testing;
};

subtest 'Doesnt parse invalid cover art relationships' => sub {
    my $release = make_release('coverart', 'http://www.google.com');

    $c->model('CoverArt')->load($release);
    ok(!$release->has_cover_art);

    done_testing;
};

# FIXME: the following tests are broken, I've made a ticket
# in jira: http://jira.musicbrainz.org/browse/MBS-785    --warp.

# subtest 'Handles Amazon ASINs' => sub {
#     my $release = make_release('asin', 'http://www.amazon.com/gp/product/B000003TA4');

#     $c->model('CoverArt')->load($release);
#     ok($release->has_cover_art);
#     ok($ua->get($release->cover_art->image_uri)->is_success);

#     done_testing;
# };

# subtest 'Handles Amazon ASINs for downloads' => sub {
#     my $release = make_release('asin', 'http://www.amazon.com/gp/product/B000W23HCY');

#     $c->model('CoverArt')->load($release);
#     ok($release->has_cover_art);
#     ok($ua->get($release->cover_art->image_uri)->is_success);

#     done_testing;
# };

done_testing;

sub make_release
{
    my ($type, $url) = @_;
    my $release = Release->new( name => 'Test release' );
    $release->add_relationship(
        Relationship->new(
            link => Link->new(
                type => LinkType->new(
                    name => $type
                ),
            ),
            entity1 => URL->new(
                url => $url,
            ),
            direction => $MusicBrainz::Server::Entity::Relationship::DIRECTION_FORWARD,
        )
    );

    return $release;
}
