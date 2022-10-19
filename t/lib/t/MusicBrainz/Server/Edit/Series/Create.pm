package t::MusicBrainz::Server::Edit::Series::Create;
use strict;
use warnings;

use Test::Routine;
use Test::More;

with 't::Edit';
with 't::Context';

use MusicBrainz::Server::Constants qw(
    $EDIT_SERIES_CREATE
    $STATUS_FAILEDVOTE
    $STATUS_OPEN
    $UNTRUSTED_FLAG
);
use MusicBrainz::Server::Test qw( reject_edit );

test 'Rejecting an "Add series" edit where the series has subscriptions (MBS-8690)' => sub {
    my ($test) = @_;

    my $c = $test->c;

    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_SERIES_CREATE,
        editor_id => 1,
        name => 'Series',
        comment => '',
        type_id => 1,
        ordering_type_id => 1,
        privileges => $UNTRUSTED_FLAG,
    );

    is($edit->status, $STATUS_OPEN);
    $c->model('Series')->subscription->subscribe(1, $edit->series_id);
    reject_edit($c, $edit);
    is($edit->status, $STATUS_FAILEDVOTE);
};

1;
