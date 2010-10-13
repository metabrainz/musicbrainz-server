use strict;
use warnings;
use Test::More;

use MusicBrainz::Server::Test;
my $c = MusicBrainz::Server::Test->create_test_context;

use DBDefs;

use aliased 'MusicBrainz::Server::Entity::Link';
use aliased 'MusicBrainz::Server::Entity::LinkType';
use aliased 'MusicBrainz::Server::Entity::Relationship';
use aliased 'MusicBrainz::Server::Entity::Release';
use aliased 'MusicBrainz::Server::Entity::URL';

use LWP::UserAgent;
my $ua = LWP::UserAgent->new;
$ua->env_proxy;

subtest 'Parses valid cover art relationships' => sub {
    my $release = make_release('cover art link', 'http://www.archive.org/download/CoverArtsForVariousAlbum/karenkong-mulakan.jpg');

    $c->model('CoverArt')->load($release);
    ok($release->has_cover_art);
    is($release->cover_art->provider->name, 'archive.org');
    is($release->cover_art->image_uri, 'http://www.archive.org/download/CoverArtsForVariousAlbum/karenkong-mulakan.jpg');

    done_testing;
};

subtest 'Doesnt parse invalid cover art relationships' => sub {
    my $release = make_release('cover art link', 'http://www.google.com');

    $c->model('CoverArt')->load($release);
    ok(!$release->has_cover_art);

    done_testing;
};

subtest 'Handles Amazon ASINs' => sub {
    plan skip_all => 'Testing Amazon ASINs requires the AWS_PUBLIC and AWS_PRIVATE configuration variables to be set'
        unless DBDefs::AWS_PUBLIC() && DBDefs::AWS_PRIVATE();

    my $release = make_release('amazon asin', 'http://www.amazon.com/gp/product/B000003TA4');

     $c->model('CoverArt')->load($release);
     ok($release->has_cover_art);
     ok($ua->get($release->cover_art->image_uri)->is_success);

     done_testing;
};

subtest 'Handles Amazon ASINs for downloads' => sub {
    plan skip_all => 'Testing Amazon ASINs requires the AWS_PUBLIC and AWS_PRIVATE configuration variables to be set'
        unless DBDefs::AWS_PUBLIC() && DBDefs::AWS_PRIVATE();

    my $release = make_release('amazon asin', 'http://www.amazon.com/gp/product/B000W23HCY');

    $c->model('CoverArt')->load($release);
    ok($release->has_cover_art);
    ok($ua->get($release->cover_art->image_uri)->is_success);

    done_testing;
};

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
