use strict;
use warnings;
use Test::More;

use List::Util qw( first );
use MusicBrainz::Server::Context;
my $c = MusicBrainz::Server::Context->create_script_context;

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

done_testing;
