package t::MusicBrainz::Server::Edit::Label::Delete;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use Test::Fatal;

with 't::Edit';
with 't::Context';

BEGIN { use MusicBrainz::Server::Edit::Label::Delete; }

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_LABEL_DELETE );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

test all => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_label_delete');

    my $label = $c->model('Label')->get_by_id(2);

    my $edit = create_edit($c, $label);
    isa_ok($edit, 'MusicBrainz::Server::Edit::Label::Delete');

    my ($edits, $hits) = $c->model('Edit')->find({ label => $label->id }, 10, 0);
    is($hits, 1);
    is($edits->[0]->id, $edit->id);

    $edit = $c->model('Edit')->get_by_id($edit->id);
    $label = $c->model('Label')->get_by_id(2);
    is($label->edits_pending, 1);

    reject_edit($c, $edit);
    $label = $c->model('Label')->get_by_id(2);
    is($label->edits_pending, 0);

    $edit = create_edit($c, $label);
    accept_edit($c, $edit);
    $label = $c->model('Label')->get_by_id(2);
    ok(!defined $label);

    my $ipi_codes = $c->model('Artist')->ipi->find_by_entity_id(2);
    is(scalar @$ipi_codes, 0, 'IPI codes for deleted label removed from database');

    my $isni_codes = $c->model('Artist')->isni->find_by_entity_id(2);
    is(scalar @$isni_codes, 0, 'ISNI codes for deleted label removed from database');
};

test 'Edit is failed if label no longer exists' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_label_delete');

    my $label = $c->model('Label')->get_by_id(2);
    my $edit1 = create_edit($c, $label);
    my $edit2 = create_edit($c, $label);

    $edit1->accept;
    isa_ok exception { $edit2->accept }, 'MusicBrainz::Server::Edit::Exceptions::FailedDependency';
};

sub create_edit {
    my ($c, $label) = @_;
    return $c->model('Edit')->create(
        edit_type => $EDIT_LABEL_DELETE,
        to_delete => $label,
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
