package t::MusicBrainz::Server::Data::Role::Name;

use strict;
use warnings;

use Test::Routine;
use Test::Moose;
use Test::More;

use MusicBrainz::Server::Data::Artist;

with 't::Edit';
with 't::Context';

test find_by_names => sub {
    my $test = shift;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+data_artist');

    # Test Data::Role::Name->find_by_names using Data::Artist.
    my $artist_data = MusicBrainz::Server::Data::Artist->new(c => $test->c);

    my %results = $artist_data->find_by_names('test artist', 'minimal Artist');

    my $testartist = $results{'test artist'};
    my $minimalartist = $results{'minimal Artist'};

    is(@$testartist, 1, 'Found one result for "test artist"');
    is(@$minimalartist, 1, 'Found one result for "minimal Artist"');

    isa_ok($testartist->[0], 'MusicBrainz::Server::Entity::Artist');
    isa_ok($minimalartist->[0], 'MusicBrainz::Server::Entity::Artist');

    is($testartist->[0]->name, 'Test Artist', 'Test Artist entity has correct name');
    is($minimalartist->[0]->name, 'Minimal Artist', 'Minimal Artist entity has correct name');
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2022 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
