package t::MusicBrainz::Server::Data::ReleasePackaging;
use strict;
use warnings;

use Test::Routine;
use Test::Moose;
use Test::More;

use MusicBrainz::Server::Data::ReleasePackaging;

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;

with 't::Context';

test all => sub {

my $test = shift;

my $lt_data = MusicBrainz::Server::Data::ReleasePackaging->new(c => $test->c);

my $lt = $lt_data->get_by_id(1);
is ( $lt->id, 1 );
is ( $lt->name, 'Jewel Case' );

my $lts = $lt_data->get_by_ids(1, 3, 666);
is ( $lts->{1}->id, 1 );
is ( $lts->{1}->name, 'Jewel Case' );
is ( $lts->{3}->id, 3 );
is ( $lts->{3}->name, 'Digipak' );
ok(!exists $lts->{666});

does_ok($lt_data, 'MusicBrainz::Server::Data::Role::SelectAll');
my @types = $lt_data->get_all;
is(@types, 6);
is_deeply([sort { $a <=> $b } map { $_->id } @types], [1, 2, 3, 4, 5, 7]);

};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
