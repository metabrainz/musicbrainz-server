package t::MusicBrainz::Server::Edit::Medium::MoveDiscID;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use Test::Fatal;

with 't::Edit';
with 't::Context';

use MusicBrainz::Server::Constants qw( $EDIT_MEDIUM_MOVE_DISCID );

BEGIN { use MusicBrainz::Server::Edit::Medium::MoveDiscID }

test all => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+cdtoc');
    MusicBrainz::Server::Test->prepare_test_database($c, <<'SQL');
        SET client_min_messages TO warning;
        DELETE FROM medium_cdtoc WHERE id = 2;
SQL

    my ($new_medium, $medium_cdtoc) = reload_data($c);

    is($medium_cdtoc->medium_id, 1);
    is($medium_cdtoc->edits_pending, 0);
    is($medium_cdtoc->medium->release->edits_pending, 0);

    create_edit($c, $new_medium, $medium_cdtoc);
    ($new_medium, $medium_cdtoc) = reload_data($c);

    is($medium_cdtoc->medium_id, 2);
    is($medium_cdtoc->edits_pending, 0);
    is($medium_cdtoc->medium->release->edits_pending, 0);
};

test 'Cannot move to non-existent medium' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+cdtoc');

    my $edit = create_edit($c, reload_data($c));
    $c->model('Medium')->delete(2);
    isa_ok exception { $edit->accept },
        'MusicBrainz::Server::Edit::Exceptions::FailedDependency';
};

test 'Moving a DiscID to the medium it already is attached to does not change anything (MBS-7043)' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+cdtoc');
    MusicBrainz::Server::Test->prepare_test_database($c, <<~'SQL');
        DELETE FROM medium_cdtoc WHERE id = 2;
        SQL

    my $medium = $c->model('Medium')->get_by_id(1);
    my $medium_cdtoc = $c->model('MediumCDTOC')->get_by_id(1);
    $c->model('Medium')->load($medium_cdtoc);
    $c->model('Release')->load($medium, $medium_cdtoc->medium);

    isa_ok exception {
        $c->model('Edit')->create(
            edit_type => $EDIT_MEDIUM_MOVE_DISCID,
            editor_id => 1,
            new_medium => $medium,
            medium_cdtoc => $medium_cdtoc,
        );
    }, 'MusicBrainz::Server::Edit::Exceptions::NoChanges';

    $medium_cdtoc = $c->model('MediumCDTOC')->get_by_id(1);
    ok(defined $medium_cdtoc, 'DiscID still exists');
    $c->model('Medium')->load($medium_cdtoc);
    is($medium_cdtoc->medium_id, 1, 'DiscID still attached to the medium');
};

sub create_edit {
    my ($c, $new_medium, $medium_cdtoc) = @_;
    return $c->model('Edit')->create(
        edit_type => $EDIT_MEDIUM_MOVE_DISCID,
        editor_id => 1,
        new_medium => $new_medium,
        medium_cdtoc => $medium_cdtoc,
    );
}

sub reload_data {
    my $c = shift;
    my $new_medium = $c->model('Medium')->get_by_id(2);
    my $medium_cdtoc = $c->model('MediumCDTOC')->get_by_id(1);
    $c->model('Medium')->load($medium_cdtoc);
    $c->model('Release')->load($new_medium, $medium_cdtoc->medium);

    return ($new_medium, $medium_cdtoc);
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
