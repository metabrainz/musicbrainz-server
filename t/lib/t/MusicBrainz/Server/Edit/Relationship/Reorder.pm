package t::MusicBrainz::Server::Edit::Relationship::Reorder;
use Test::Routine;
use Test::More;

with 't::Edit';
with 't::Context';

BEGIN { use MusicBrainz::Server::Edit::Relationship::Reorder }

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_RELATIONSHIPS_REORDER );

test all => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+series');

    my $rels = $c->model('Relationship')->get_by_ids('series', 'work', 1..4);
    $c->model('Link')->load(values %$rels);
    $c->model('LinkType')->load(map { $_->link } values %$rels);

    is($rels->{1}->link_order, 1);
    is($rels->{2}->link_order, 2);
    is($rels->{3}->link_order, 3);
    is($rels->{4}->link_order, 4);

    my %edit_args = (
        edit_type => $EDIT_RELATIONSHIPS_REORDER,
        editor_id => 1,
        link_type_id => 743,
        relationship_order => [
            { relationship => $rels->{1}, old_order => 1, new_order => 4 },
            { relationship => $rels->{2}, old_order => 2, new_order => 3 },
            { relationship => $rels->{3}, old_order => 3, new_order => 2 },
            { relationship => $rels->{4}, old_order => 4, new_order => 1 },
        ]
    );

    my $edit = $c->model('Edit')->create(%edit_args);

    my ($edits, $hits) = $c->model('Edit')->find({ series => 2 }, 10, 0);
    is($hits, 1, 'Found 1 edit for series 2');
    is($edits->[0]->id, $edit->id, '... which has the same id as the edit just created');

    for my $i (1..4) {
        ($edits, $hits) = $c->model('Edit')->find({ work => $i }, 10, 0);
        is($hits, 1, "Found 1 edit for work $i");
        is($edits->[0]->id, $edit->id, '... which has the same id as the edit just created');
    }

    $rels = $c->model('Relationship')->get_by_ids('series', 'work', 1..4);
    $c->model('Link')->load(values %$rels);
    $c->model('LinkType')->load(map { $_->link } values %$rels);

    is($rels->{1}->link_order, 4);
    is($rels->{2}->link_order, 3);
    is($rels->{3}->link_order, 2);
    is($rels->{4}->link_order, 1);
};

1;
