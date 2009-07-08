#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 20;
use Test::Moose;
use_ok 'MusicBrainz::Server::Data::Gender';

use MusicBrainz::Server::Entity::Gender;
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c, '+gender');

my $gender_data = MusicBrainz::Server::Data::Gender->new(c => $c);

my $gender = $gender_data->get_by_id(1);
is ( $gender->id, 1 );
is ( $gender->name, "Male" );

$gender = $gender_data->get_by_id(2);
is ( $gender->id, 2 );
is ( $gender->name, "Female" );

my $genders = $gender_data->get_by_ids(1, 2);
is ( $genders->{1}->id, 1 );
is ( $genders->{1}->name, "Male" );

is ( $genders->{2}->id, 2 );
is ( $genders->{2}->name, "Female" );

does_ok($gender_data, 'MusicBrainz::Server::Data::SelectAll');
my @gs = $gender_data->get_all;
is(@gs, 2);
is($gs[0]->id, 1);
is($gs[1]->id, 2);

my $sql = Sql->new($c->mb->dbh);
$sql->Begin;

my $new_gender = $gender_data->insert({ name => 'Unknown' });
ok(defined $new_gender, 'should return instantiated object');
isa_ok($new_gender, 'MusicBrainz::Server::Entity::Gender');
ok(defined $new_gender->id, 'id should be defined');
ok($new_gender->id > 2, 'should be >2 from sequence');
is($new_gender->name, 'Unknown');

my $created = $gender_data->get_by_id($new_gender->id);
ok(defined $created);
is_deeply($created, $new_gender, 'getting gender should be same as created gender');
$sql->Commit;
