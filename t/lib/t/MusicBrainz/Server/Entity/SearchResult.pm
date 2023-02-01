package t::MusicBrainz::Server::Entity::SearchResult;
use strict;
use warnings;

use Test::Routine;
use Test::Moose;
use Test::More;

use MusicBrainz::Server::Entity::Artist;
use MusicBrainz::Server::Entity::Release;
use MusicBrainz::Server::Entity::SearchResult;

=head1 DESCRIPTION

This test ensures that SearchResult has the expected attributes and that
it stores data correctly.

=cut

test 'SearchResult has the expected attributes' => sub {
    my $searchresult = MusicBrainz::Server::Entity::SearchResult->new();
    has_attribute_ok($searchresult, $_) for qw( entity extra position score );
};

test 'SearchResult stores data correctly' => sub {
    my $searchresult = MusicBrainz::Server::Entity::SearchResult->new();

    note('We add an artist as the result entity');
    my $artist = MusicBrainz::Server::Entity::Artist->new(id => 42);
    $searchresult->entity($artist);
    is(
        $searchresult->entity->entity_type,
        'artist',
        'The stored result entity is an artist',
    );
    is(
        $searchresult->entity->id,
        42,
        'The stored result entity has the right id',
    );

    note('We add an "extra" section to the result');
    my $release = MusicBrainz::Server::Entity::Release->new(id => 42);
    $searchresult->extra( [{
        release => $release,
        track_position      => 1,
        medium_position     => 1,
        medium_track_count  => 1,
    }] );
    is(
        $searchresult->extra->[0]->{release}->id,
        42,
        'The stored extra data includes a release with the right id',
    );
    is(
        $searchresult->extra->[0]->{medium_position},
        1,
        'The stored extra data includes the right medium_position',
    );
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
