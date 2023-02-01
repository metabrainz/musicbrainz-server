package t::MusicBrainz::Server::Edit::Work::Merge;
use strict;
use warnings;

use Test::Routine;
use Test::More;

with 't::Edit';
with 't::Context';

BEGIN { use MusicBrainz::Server::Edit::Work::Merge }

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_WORK_MERGE );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

test all => sub {

my $test = shift;
my $c = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+work');

my $edit = create_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::Work::Merge');

my ($edits, $hits) = $c->model('Edit')->find({ work => [1, 2] }, 10, 0);
is($hits, 1);
is($edits->[0]->id, $edit->id);

my $a1 = $c->model('Work')->get_by_id(1);
my $a2 = $c->model('Work')->get_by_id(2);
is($a1->edits_pending, 1);
is($a2->edits_pending, 1);

reject_edit($c, $edit);

$a1 = $c->model('Work')->get_by_id(1);
$a2 = $c->model('Work')->get_by_id(2);
is($a1->edits_pending, 0);
is($a2->edits_pending, 0);

$edit = create_edit($c);
accept_edit($c, $edit);

$a1 = $c->model('Work')->get_by_id(1);
$a2 = $c->model('Work')->get_by_id(2);
ok(!defined $a1);
ok(defined $a2);

is($a2->edits_pending, 0);

};

sub create_edit {
    my $c = shift;
    return $c->model('Edit')->create(
        edit_type => $EDIT_WORK_MERGE,
        editor_id => 1,
        old_entities => [ { id => 1, name => 'Old Work' } ],
        new_entity => { id => 2, name => 'New Work' },
    );
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
