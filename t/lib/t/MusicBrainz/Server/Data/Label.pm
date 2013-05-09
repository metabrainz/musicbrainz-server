package t::MusicBrainz::Server::Data::Label;
use Test::Routine;
use Test::Moose;
use Test::More;
use Test::Fatal;

use MusicBrainz::Server::Data::Label;
use MusicBrainz::Server::Data::Search;

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;
use MusicBrainz::Server::Constants qw($DLABEL_ID);
use Sql;

with 't::Context';

test all => sub {

    my $test = shift;
    MusicBrainz::Server::Test->prepare_test_database($test->c, '+label');

    my $label_data = MusicBrainz::Server::Data::Label->new(c => $test->c);

    my $label = $label_data->get_by_id(3);
    is ( $label->id, 3, "id");
    is ( $label->gid, "46f0f4cd-8aab-4b33-b698-f459faf64190", "gid" );
    is ( $label->name, "Warp Records", "label name" );
    is ( $label->sort_name, "Warp Records", "sort name" );
    is ( $label->begin_date->year, 1989, "begin date, year");
    is ( $label->begin_date->month, 2, "begin date, month" );
    is ( $label->begin_date->day, 3, "begin date, day" );
    is ( $label->end_date->year, 2008, "end date, year" );
    is ( $label->end_date->month, 5, "end date, month" );
    is ( $label->end_date->day, 19, "end date, day" );
    is ( $label->edits_pending, 0, "no edits pending" );
    is ( $label->type_id, 1, "type id" );
    is ( $label->label_code, 2070, "label code" );
    is ( $label->format_label_code, 'LC 02070', "formatted label code" );
    is ( $label->comment, 'Sheffield based electronica label', "comment" );

    my $annotation = $label_data->annotation->get_latest(3);
    is ( $annotation->text, "Label Annotation", "annotation" );


    $label = $label_data->get_by_gid('efdf3fe9-c293-4acd-b4b2-8d2a7d4f9592');
    is ( $label->id, 3, "get label by gid" );


    my $search = MusicBrainz::Server::Data::Search->new(c => $test->c);
    my ($results, $hits) = $search->search("label", "Warp", 10);
    is( $hits, 1, "Searching for Warp, 1 hit" );
    is( scalar(@$results), 1, "Searching for Warp, 1 result" );
    is( $results->[0]->position, 1 );
    is( $results->[0]->entity->name, "Warp Records", "Found Warp Records");
    is( $results->[0]->entity->sort_name, "Warp Records", "Found Warp Records");

    my %names = $label_data->find_or_insert_names('Warp Records', 'RAM Records');
    is(keys %names, 2);
    is($names{'Warp Records'}, 1);
    ok($names{'RAM Records'} > 1);


    $test->c->sql->begin;

    $label = $label_data->insert({
        name => 'RAM Records',
        sort_name => 'RAM Records',
        type_id => 1,
        area_id => 221,
        ipi_codes => [ '00407982340' ],
        isni_codes => [ '0000000106750994' ],
        end_date => { year => 2000, month => 05 }
                                 });
    isa_ok($label, 'MusicBrainz::Server::Entity::Label');
    ok($label->id > 1);


    # ---
    # Missing entities search
    my $found = $label_data->search_by_names();
    is(scalar keys %$found, 0, "Nothing found when searching for nothing");

    $found = $label_data->search_by_names('Warp Records');
    isa_ok($found->{'Warp Records'}->[0], 'MusicBrainz::Server::Entity::Label');

    $found = $label_data->search_by_names('RAM Records', 'Warp Records', 'Not there');
    isa_ok($found->{'Warp Records'}->[0], 'MusicBrainz::Server::Entity::Label');
    isa_ok($found->{'RAM Records'}->[0], 'MusicBrainz::Server::Entity::Label');
    ok(!defined $found->{'Not there'}, 'Non existent label was not found');

    ok(!$test->c->model('Label')->in_use($label->id));

    $label = $label_data->get_by_id($label->id);
    is($label->name, 'RAM Records', "name");
    is($label->sort_name, 'RAM Records', "sort name");
    is($label->type_id, 1, "type id");
    is($label->area_id, 221, "area id");
    ok(!$label->end_date->is_empty, "end date is not empty");
    is($label->end_date->year, 2000, "end date, year");
    is($label->end_date->month, 5, "end date, month");

    $label_data->update($label->id, {
        sort_name => 'Records, RAM',
        begin_date => { year => 1990 },
        ipi_codes => [ '00407982341' ],
        isni_codes => [ '0000000106750995' ],
        comment => 'Drum & bass label'
    });

    $label = $label_data->get_by_id($label->id);
    is($label->name, 'RAM Records', "name hasn't changed");
    is($label->sort_name, 'Records, RAM', "sort name updated");
    is($label->comment, 'Drum & bass label', "comment updated");
    ok(!$label->begin_date->is_empty, "begin date is not empty");
    ok(!$label->end_date->is_empty, "end date is not empty");
    is($label->begin_date->year, 1990, "begin date, year");
    is($label->end_date->year, 2000, "end date, year");
    is($label->end_date->month, 5, "end date, month");

    $label_data->delete($label->id);
    $label = $label_data->get_by_id($label->id);
    ok(!defined $label, "label deleted");

    $label_data->merge(3, 2);
    $label = $label_data->get_by_id(2);
    ok(!defined $label, "label merged");

    $label = $label_data->get_by_id(3);
    ok(defined $label, "label merged");

    $test->c->sql->commit;

};

test 'Deny delete "Deleted Label" trigger' => sub {
    my $c = shift->c;
    MusicBrainz::Server::Test->prepare_test_database($c, '+special-purpose');

    like exception {
        $c->sql->do ("DELETE FROM artist WHERE id = $DLABEL_ID")
    }, qr/ERROR:\s*Attempted to delete a special purpose row/;
};

test 'Cannot edit an label into something that would violate uniqueness' => sub {
    my $c = shift->c;
    $c->sql->do(<<'EOSQL');
INSERT INTO label_name (id, name) VALUES (1, 'A'), (2, 'B');
INSERT INTO label (id, gid, name, sort_name, comment) VALUES
  (3, '745c079d-374e-4436-9448-da92dedef3ce', 1, 1, ''),
  (4, '7848d7ce-d650-40c4-b98f-62fc037a678b', 2, 1, 'Comment');
EOSQL

    my $conflicts_exception_ok = sub {
        my ($e, $target) = @_;

        isa_ok $e, 'MusicBrainz::Server::Exceptions::DuplicateViolation';
        is $e->conflict->id, $target;
    };

    ok !exception { $c->model('Label')->update(4, { comment => '' }) };
    $conflicts_exception_ok->(
        exception { $c->model('Label')->update(3, { name => 'B' }) },
        4
    );

    ok !exception { $c->model('Label')->update(3, { name => 'B', comment => 'Unique' }) };
    $conflicts_exception_ok->(
        exception { $c->model('Label')->update(3, { comment => '' }) },
        4
    );
};

1;
