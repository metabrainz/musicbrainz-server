package t::MusicBrainz::Server::Data::CoverArt;
use Test::Routine;
use Test::Moose;
use Test::More;

use DBDefs;
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
        unless DBDefs::AWS_PUBLIC() && DBDefs::AWS_PRIVATE();

    my $test = shift;

    my $release = make_release('amazon asin', 'http://www.amazon.com/gp/product/B000003TA4');

    $test->c->model('CoverArt')->load($release);
    ok($release->has_cover_art);
    ok($test->ua->get($release->cover_art->image_uri)->is_success);

};

test 'Handles Amazon ASINs for downloads' => sub {
    plan skip_all => 'Testing Amazon ASINs requires the AWS_PUBLIC and AWS_PRIVATE configuration variables to be set'
        unless DBDefs::AWS_PUBLIC() && DBDefs::AWS_PRIVATE();

    my $test = shift;

    my $release = make_release('amazon asin', 'http://www.amazon.com/gp/product/B000W23HCY');

    $test->c->model('CoverArt')->load($release);
    ok($release->has_cover_art);
    ok($test->ua->get($release->cover_art->image_uri)->is_success);

};

test 'Searching Amazon by barcode' => sub {
    plan skip_all => 'Testing Amazon barcode searches requires the AWS_PUBLIC and AWS_PRIVATE configuration variables to be set'
        unless DBDefs::AWS_PUBLIC() && DBDefs::AWS_PRIVATE();

    my $test = shift;

    my $release = Release->new( name => 'Symmetry', barcode => '5060157037002' );

    $test->c->model('CoverArt')->load($release);
    ok($release->has_cover_art);
    ok($test->ua->get($release->cover_art->image_uri)->is_success);

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
