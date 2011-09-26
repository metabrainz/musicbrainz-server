use strict;
use warnings;
use Test::More;

use aliased 'MusicBrainz::Server::CoverArt::Provider::RegularExpression' => 'Provider::RegularExpression';

my $provider = Provider::RegularExpression->new(
    name               => 'Discogs',
    domain             => 'discogs.com',
    uri_expression     => 'http://www.discogs.com/image/R-(\d+)-(\d+).jpeg',
    image_uri_template => 'http://www.discogs.com/image/R-$1-$2.jpeg',
    info_uri_template  => 'http://www.discogs.com/release/$1',
);

subtest 'Test a valid URI' => sub {
    my $uri = 'http://www.discogs.com/image/R-1764263-1241867480.jpeg';
    ok($provider->handles($uri));

    my $art = $provider->lookup_cover_art($uri);
    is($art->provider->name, 'Discogs');
    is($art->image_uri, 'http://www.discogs.com/image/R-1764263-1241867480.jpeg');
    is($art->information_uri, 'http://www.discogs.com/release/1764263');

    done_testing;
};

subtest 'Test case sensitivy' => sub {
    my $uri = 'http://www.discogs.com/image/R-1764263-1241867480.jPeG';
    ok($provider->handles($uri));

    my $art = $provider->lookup_cover_art($uri);
    is($art->provider->name, 'Discogs');
    is($art->image_uri, 'http://www.discogs.com/image/R-1764263-1241867480.jpeg');
    is($art->information_uri, 'http://www.discogs.com/release/1764263');

    done_testing;
};

subtest 'Test an invalid URI' => sub {
    my $uri = 'http://gizoogle.com';
    ok(!$provider->handles($uri));

    my $art = $provider->lookup_cover_art($uri);
    ok(!defined $art);

    done_testing;
};

done_testing;
