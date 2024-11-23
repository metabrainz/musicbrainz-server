package t::MusicBrainz::Server::Edit::Artist::Delete;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use Test::Fatal;

with 't::Edit';
with 't::Context';

BEGIN { use MusicBrainz::Server::Edit::Artist::Delete }

use MusicBrainz::Server::Constants qw(
    :edit_status
    $EDITOR_MODBOT
    $EDIT_ARTIST_DELETE
);
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

test all => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_artist_delete');

    my $artist = $c->model('Artist')->get_by_id(3);

    my $edit = create_edit($c, $artist);
    isa_ok($edit, 'MusicBrainz::Server::Edit::Artist::Delete');

    my ($edits, $hits) = $c->model('Edit')->find({ artist => 3 }, 10, 0);
    is($hits, 1);
    is($edits->[0]->id, $edit->id);

    $artist = $c->model('Artist')->get_by_id(3);
    is($artist->edits_pending, 1);

    # Test rejecting the edit
    reject_edit($c, $edit);
    $artist = $c->model('Artist')->get_by_id(3);
    ok(defined $artist);
    is($artist->edits_pending, 0);

    # Test accepting the edit
    # This should fail as the artist has a recording linked
    $edit = create_edit($c, $artist);
    accept_edit($c, $edit);
    $artist = $c->model('Artist')->get_by_id(3);
    is($edit->status, $STATUS_FAILEDDEP);
    ok(defined $artist);

    # Delete the recording and enter the edit
    my $sql = $c->sql;
    Sql::run_in_transaction(sub { $c->model('Recording')->delete(1) }, $sql);

    $edit = create_edit($c, $artist);
    accept_edit($c, $edit);
    $artist = $c->model('Artist')->get_by_id(3);
    ok(!defined $artist);

    my $ipi_codes = $c->model('Artist')->ipi->find_by_entity_id(3);
    is(scalar @$ipi_codes, 0, 'IPI codes for deleted artist removed from database');

    my $isni_codes = $c->model('Artist')->isni->find_by_entity_id(3);
    is(scalar @$isni_codes, 0, 'ISNI codes for deleted artist removed from database');
};

test 'Can be entered as an auto-edit' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_artist_delete');

    my $artist = $c->model('Artist')->get_by_id(3);

    # Delete the recording and enter the edit
    my $sql = $c->sql;
    Sql::run_in_transaction(
        sub {
            $c->model('Recording')->delete(1);
        }, $sql);
    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_ARTIST_DELETE,
        to_delete => $artist,
        editor_id => $EDITOR_MODBOT,
        privileges => 1,
    );
    isa_ok($edit, 'MusicBrainz::Server::Edit::Artist::Delete');

    $artist = $c->model('Artist')->get_by_id(3);
    ok(!defined $artist);
};

test 'Edit is failed if artist no longer exists' => sub {
    my $test = shift;
    my $c = $test->c;

    my $artist_row = $c->model('Artist')->insert({
        name => 'Gonna B Deleted',
        sort_name => 'Gonna B Deleted',
    });

    my $artist = $c->model('Artist')->get_by_id($artist_row->{id});
    my $edit1 = create_edit($c, $artist);
    my $edit2 = create_edit($c, $artist);

    $edit1->accept;
    isa_ok exception { $edit2->accept }, 'MusicBrainz::Server::Edit::Exceptions::FailedDependency';
};

sub create_edit {
    my ($c, $artist) = @_;
    return $c->model('Edit')->create(
        edit_type => $EDIT_ARTIST_DELETE,
        to_delete => $artist,
        editor_id => 1,
    );
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
