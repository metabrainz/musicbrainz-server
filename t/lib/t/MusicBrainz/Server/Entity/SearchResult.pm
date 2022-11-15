package t::MusicBrainz::Server::Entity::SearchResult;
use strict;
use warnings;

use Test::Routine;
use Test::Moose;
use Test::More;

use MusicBrainz::Server::Entity::Artist;
use MusicBrainz::Server::Entity::Release;


use MusicBrainz::Server::Entity::SearchResult;

test all => sub {

my $searchresult = MusicBrainz::Server::Entity::SearchResult->new();
has_attribute_ok($searchresult, $_) for qw( position score );

my $artist = MusicBrainz::Server::Entity::Artist->new();
$searchresult->entity($artist);
ok( defined $searchresult->entity );

my $release = MusicBrainz::Server::Entity::Release->new();
$searchresult->extra( [{
    release => $release,
    track_position      => 1,
    medium_position     => 1,
    medium_track_count  => 1,
}] );
ok( defined $searchresult->extra );

};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
