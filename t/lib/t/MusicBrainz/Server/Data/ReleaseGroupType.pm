package t::MusicBrainz::Server::Data::ReleaseGroupType;
use strict;
use warnings;

use Test::Routine;
use Test::Moose;
use Test::More;

use MusicBrainz::Server::Data::ReleaseGroupType;

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;

with 't::Context';

test all => sub {

my $test = shift;

my $rgt_data = MusicBrainz::Server::Data::ReleaseGroupType->new(c => $test->c);

my $rgt = $rgt_data->get_by_id(1);
is ( $rgt->id, 1 );
is ( $rgt->name, 'Album' );

$rgt = $rgt_data->get_by_id(2);
is ( $rgt->id, 2 );
is ( $rgt->name, 'Single' );

my $rgts = $rgt_data->get_by_ids(1, 2);
is ( $rgts->{1}->id, 1 );
is ( $rgts->{1}->name, 'Album' );

is ( $rgts->{2}->id, 2 );
is ( $rgts->{2}->name, 'Single' );


does_ok($rgt_data, 'MusicBrainz::Server::Data::Role::SelectAll');
my @types = $rgt_data->get_all;
is(@types, 5);
is($types[0]->id, 1);
is($types[1]->id, 2);
is($types[2]->id, 3);
is($types[3]->id, 11);
is($types[4]->id, 12);


};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
