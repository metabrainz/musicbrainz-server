package t::MusicBrainz::Server::Data::Gender;
use strict;
use warnings;

use Test::Routine;
use Test::Moose;
use Test::More;
use Test::Deep qw( cmp_bag );

use MusicBrainz::Server::Data::Gender;

use MusicBrainz::Server::Entity::Gender;
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;
use MusicBrainz::Server::Test::Utils qw( verify_name_and_id );

with 't::Context';

=head1 DESCRIPTION

This test checks the different getters for Gender, plus gender insertion.

=cut

test 'get_by_id' => sub {
    my $test = shift;
    my $c = $test->c;

    my $gender_data = MusicBrainz::Server::Data::Gender->new(c => $c);

    my $gender = $gender_data->get_by_id(1);
    verify_name_and_id(1, 'Male', $gender);

    $gender = $gender_data->get_by_id(2);
    verify_name_and_id(2, 'Female', $gender);
};

test 'get_by_ids' => sub {
    my $test = shift;
    my $c = $test->c;

    my $gender_data = MusicBrainz::Server::Data::Gender->new(c => $c);

    my @requested_ids = (1, 2);

    my $genders = $gender_data->get_by_ids(@requested_ids);
    cmp_bag(
        [keys %$genders],
        \@requested_ids,
        'The keys of the returned hash are the requested row ids',
    );
    verify_name_and_id(1, 'Male', $genders->{1});
    verify_name_and_id(2, 'Female', $genders->{2});
};

test 'get_all' => sub {
    my $test = shift;
    my $c = $test->c;

    my $gender_data = MusicBrainz::Server::Data::Gender->new(c => $c);

    does_ok($gender_data, 'MusicBrainz::Server::Data::Role::SelectAll');
    my @genders = sort { $a->{id} <=> $b->{id} } $gender_data->get_all;
    is(@genders, 3, 'get_all returns all 3 genders');
    verify_name_and_id(1, 'Male', $genders[0]);
    verify_name_and_id(2, 'Female', $genders[1]);
    verify_name_and_id(3, 'Other', $genders[2]);
};

test 'Inserting and getting new gender' => sub {
    my $test = shift;
    my $c = $test->c;

    my $gender_data = MusicBrainz::Server::Data::Gender->new(c => $c);
    my $sql = $test->c->sql;
    $sql->begin;

    my $gender_name = 'Unknown';
    my $gender_gid = '181c0bf5-da60-37b0-95f8-2207a3f7f9d6';
    my $new_gender = $gender_data->insert({
        name => $gender_name,
        gid => $gender_gid,
    });
    ok(defined $new_gender, 'An instantiated object is returned');
    isa_ok($new_gender, 'MusicBrainz::Server::Entity::Gender');
    ok(defined $new_gender->id, 'The returned gender has a defined row id');
    ok(
        $new_gender->id > 3,
        'The row id is larger than the previous max sequence for the table',
    );
    is(
        $new_gender->name,
        $gender_name,
        'The gender name returned by the insert matches the submitted one',
    );
    is(
        $new_gender->gid,
        $gender_gid,
        'The gender MBID returned by the insert matches the submitted one',
    );

    my $created = $gender_data->get_by_id($new_gender->id);
    ok(defined $created, 'get_by_id with the new id returns a gender');
    is(
        $created->name,
        $gender_name,
        'The gender name gotten by get_by_id matches the submitted one',
    );
    is(
        $created->gid,
        $gender_gid,
        'The gender MBID gotten by get_by_id matches the submitted one',
    );
    is(
        $created->id,
        $new_gender->id,
        'The gender id gotten by get_by_id matches the one returned by the insert',
    );
    $sql->commit;
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
