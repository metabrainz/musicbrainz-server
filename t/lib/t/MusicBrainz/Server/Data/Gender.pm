package t::MusicBrainz::Server::Data::Gender;
use strict;
use warnings;

use Test::Routine;
use Test::Moose;
use Test::More;

use MusicBrainz::Server::Data::Gender;

use MusicBrainz::Server::Entity::Gender;
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;

with 't::Context';

test all => sub {

my $test = shift;
MusicBrainz::Server::Test->prepare_test_database($test->c);

my $gender_data = MusicBrainz::Server::Data::Gender->new(c => $test->c);

my $gender = $gender_data->get_by_id(1);
is ( $gender->id, 1 );
is ( $gender->name, 'Male' );


$gender = $gender_data->get_by_id(2);
is ( $gender->id, 2 );
is ( $gender->name, 'Female' );

my $genders = $gender_data->get_by_ids(1, 2);
is ( $genders->{1}->id, 1 );
is ( $genders->{1}->name, 'Male' );

is ( $genders->{2}->id, 2 );
is ( $genders->{2}->name, 'Female' );

does_ok($gender_data, 'MusicBrainz::Server::Data::Role::SelectAll');
my @gs = $gender_data->get_all;
is(@gs, 3);
is($gs[0]->id, 1);
is($gs[1]->id, 2);


my $sql = $test->c->sql;
$sql->begin;

my $new_gender = $gender_data->insert({
  name => 'Unknown',
  gid => '181c0bf5-da60-37b0-95f8-2207a3f7f9d6',
});
ok(defined $new_gender, 'should return instantiated object');
isa_ok($new_gender, 'MusicBrainz::Server::Entity::Gender');
ok(defined $new_gender->id, 'id should be defined');
ok($new_gender->id > 2, 'should be >2 from sequence');
is($new_gender->name, 'Unknown');


my $created = $gender_data->get_by_id($new_gender->id);
ok(defined $created);
is_deeply($created->name, $new_gender->name, 'getting gender should be same as created gender');
is_deeply($created->id, $new_gender->id, 'getting gender should be same as created gender');
$sql->commit;

};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
