package t::MusicBrainz::Server::Entity::Medium;
use Test::Routine;
use Test::Moose;
use Test::More;
use Test::Deep qw( cmp_deeply ignore );

use MusicBrainz::Server::Constants qw( :direction );
use aliased 'MusicBrainz::Server::Entity::Artist';
use aliased 'MusicBrainz::Server::Entity::Link';
use aliased 'MusicBrainz::Server::Entity::LinkType';
use aliased 'MusicBrainz::Server::Entity::Medium';
use aliased 'MusicBrainz::Server::Entity::PartialDate';
use aliased 'MusicBrainz::Server::Entity::Recording';
use aliased 'MusicBrainz::Server::Entity::Relationship';
use aliased 'MusicBrainz::Server::Entity::Track';

test 'combined_track_relationships' => sub {
    my $medium = Medium->new();

    for my $i (1..6) {
        $medium->add_track(Track->new(
            id => $i,
            number => $i,
            position => $i,
            recording => Recording->new(id => $i),
            recording_id => $i
        ));
    }

    my $link_type = LinkType->new(
        id => 1,
        link_phrase => 'performed by',
        reverse_link_phrase => 'performed',
        entity0_type => 'artist',
        entity1_type => 'recording'
    );

    my $link = Link->new(
        type => $link_type,
        attributes => [],
        begin_date => PartialDate->new(),
        end_date => PartialDate->new()
    );

    my $artist = Artist->new(id => 1, name => 'Person', sort_name => 'Person');

    for my $i (0, 2, 3, 5) {
        my $recording = $medium->tracks->[$i]->recording;

        $medium->tracks->[$i]->recording->add_relationship(
            Relationship->new(
                direction => $DIRECTION_BACKWARD,
                link => $link,
                entity0 => $artist,
                entity1 => $recording,
                source => $recording,
                target => $artist,
                source_type => 'recording',
                target_type => 'artist',
            )
        );
    }

    cmp_deeply($medium->combined_track_relationships, {
        artist => [
            {
                phrase => 'performed',
                items => [
                    {
                        relationship => ignore(),
                        track_count => 4,
                        tracks => '1, 3&#x2013;4, 6'
                    }
                ]
            }
        ]
    });
};

test 'has_multiple_artists' => sub {
    my $medium = Medium->new(
        release => MusicBrainz::Server::Entity::Release->new(artist_credit_id => 1)
    );

    $medium->add_track(Track->new(artist_credit_id => 1));
    is($medium->has_multiple_artists, 0, 'Medium does not have multiple artists');

    $medium->add_track(Track->new(artist_credit_id => 2));
    is($medium->has_multiple_artists, 1, 'Medium has multiple artists');
};

1;
