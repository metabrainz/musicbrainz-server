package t::MusicBrainz::Server::Data::CoverArt;
use Test::Routine;
use Test::Moose;
use Test::More;

use DBDefs;
use List::Util qw( first );
use LWP::UserAgent;
use MusicBrainz::Server::Test;

use aliased 'MusicBrainz::Server::Entity::Link';
use aliased 'MusicBrainz::Server::Entity::LinkType';
use aliased 'MusicBrainz::Server::Entity::Relationship';
use aliased 'MusicBrainz::Server::Entity::Release';
use aliased 'MusicBrainz::Server::Entity::URL';

with 't::Context';

has 'ua' => (
    is => 'ro',
    default => sub {
        my $ua = LWP::UserAgent->new;
        $ua->env_proxy;
        return $ua;
    }
);

test 'Parses valid cover art relationships' => sub {
    my $test = shift;

    my $release = make_release('cover art link', 'http://www.archive.org/download/CoverArtsForVariousAlbum/karenkong-mulakan.jpg');

    $test->c->model('CoverArt')->load($release);
    ok($release->has_cover_art);
    is($release->cover_art->provider->name, 'archive.org');
    is($release->cover_art->image_uri, 'http://www.archive.org/download/CoverArtsForVariousAlbum/karenkong-mulakan.jpg');

};

test 'Doesnt parse invalid cover art relationships' => sub {
    my $test = shift;

    my $release = make_release('cover art link', 'http://www.google.com');

    $test->c->model('CoverArt')->load($release);
    ok(!$release->has_cover_art);

};

test 'Handles Amazon ASINs' => sub {
    plan skip_all => 'Testing Amazon ASINs requires the AWS_PUBLIC and AWS_PRIVATE configuration variables to be set'
        unless DBDefs->AWS_PUBLIC() && DBDefs->AWS_PRIVATE();

    my $test = shift;

    my $release = make_release('amazon asin', 'http://www.amazon.com/gp/product/B000003TA4');

    $test->c->model('CoverArt')->load($release);
    ok($release->has_cover_art);
    ok($test->ua->get($release->cover_art->image_uri)->is_success);

};

test 'Handles Amazon ASINs for downloads' => sub {
    plan skip_all => 'Testing Amazon ASINs requires the AWS_PUBLIC and AWS_PRIVATE configuration variables to be set'
        unless DBDefs->AWS_PUBLIC() && DBDefs->AWS_PRIVATE();

    my $test = shift;

    my $release = make_release('amazon asin', 'http://www.amazon.com/gp/product/B000W23HCY');

    $test->c->model('CoverArt')->load($release);
    ok($release->has_cover_art);
    ok($test->ua->get($release->cover_art->image_uri)->is_success);

};

test 'Check cover art provider regular expression matching' => sub {
    my $test = shift;
    my $c = $test->c;

    my $tv_provider = first { $_->name eq 'Manj\'Disc' } @{ $c->model('CoverArt')->providers };
    my $archive_provider = first { $_->name eq 'archive.org' } @{ $c->model('CoverArt')->providers };

    subtest 'Test a valid URI' => sub {
        my $uri = 'http://www.mange-disque.tv/fs/md_429.jpg';
        ok($tv_provider->handles($uri));

        my $art = $tv_provider->lookup_cover_art($uri);
        is($art->provider->name, 'Manj\'Disc');
        is($art->image_uri, 'http://www.mange-disque.tv/fs/md_429.jpg');
        is($art->information_uri, 'http://www.mange-disque.tv/info_disque.php3?dis_code=429');
    };

    subtest 'Test case sensitivy' => sub {
        my $uri = 'http://www.mange-disque.tv/fs/md_429.JPg';
        ok($tv_provider->handles($uri));

        my $art = $tv_provider->lookup_cover_art($uri);
        is($art->provider->name, 'Manj\'Disc');
        is($art->image_uri, 'http://www.mange-disque.tv/fs/md_429.jpg');
        is($art->information_uri, 'http://www.mange-disque.tv/info_disque.php3?dis_code=429');
    };

    subtest 'Test an invalid URI' => sub {
        my $uri = 'http://gizoogle.com';
        ok(!$tv_provider->handles($uri));

        my $art = $tv_provider->lookup_cover_art($uri);
        ok(!defined $art);
    };

    subtest 'Archive.org without extensions' => sub {
        my $uri = 'http://web.archive.org/web/20100106001607/http://negativland.com/img_products/101';
        ok($archive_provider->handles($uri));

        my $art = $archive_provider->lookup_cover_art($uri);
        is($art->provider->name, 'archive.org');
        is($art->image_uri, 'http://web.archive.org/web/20100106001607/http://negativland.com/img_products/101');
        is($art->information_uri, undef);
    };

    subtest 'Archive.org with extensions' => sub {
        my $uri = 'http://web.archive.org/web/20100106001607/http://negativland.com/img_products/101.jpg';
        ok($archive_provider->handles($uri));

        my $art = $archive_provider->lookup_cover_art($uri);
        is($art->provider->name, 'archive.org');
        is($art->image_uri, 'http://web.archive.org/web/20100106001607/http://negativland.com/img_products/101.jpg');
        is($art->information_uri, undef);
    };
};

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


1;
