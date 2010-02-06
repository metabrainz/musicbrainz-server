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

subtest 'Parses valid cover art relationships' => sub {
    my $release = Release->new( name => 'Test release' );
    $release->add_relationship(
        Relationship->new(
            link => Link->new(
                type => LinkType->new(
                    name => 'coverart'
                ),
            ),
            entity1 => URL->new(
                url => 'http://www.archive.org/download/CoverArtsForVariousAlbum/karenkong-mulakan.jpg',
            ),
            direction => $MusicBrainz::Server::Entity::Relationship::DIRECTION_FORWARD,
        )
    );


    $c->model('CoverArt')->load($release);
    ok($release->has_cover_art);
    is($release->cover_art->provider->name, 'archive.org');
    is($release->cover_art->image_uri, 'http://www.archive.org/download/CoverArtsForVariousAlbum/karenkong-mulakan.jpg');

    done_testing;
};

subtest 'Doesnt parse invalid cover art relationships' => sub {
    my $release = Release->new( name => 'Test release' );
    $release->add_relationship(
        Relationship->new(
            link => Link->new(
                type => LinkType->new(
                    name => 'coverart'
                ),
            ),
            entity1 => URL->new(
                url => 'http://www.google.com',
            ),
            direction => $MusicBrainz::Server::Entity::Relationship::DIRECTION_FORWARD,
        )
    );

    $c->model('CoverArt')->load($release);
    ok(!$release->has_cover_art);

    done_testing;
};

done_testing;
