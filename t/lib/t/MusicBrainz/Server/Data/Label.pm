package t::MusicBrainz::Server::Data::Label;
use Test::Routine;
use Test::Moose;
use Test::More;
use Test::Memory::Cycle;

use MusicBrainz::Server::Data::Label;
use MusicBrainz::Server::Data::Search;

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;
use Sql;

with 't::Context';

test all => sub {

my $test = shift;
MusicBrainz::Server::Test->prepare_test_database($test->c, '+label');

my $label_data = MusicBrainz::Server::Data::Label->new(c => $test->c);
memory_cycle_ok($label_data);

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
is ( $label->ipi_code, '00407982339', "ipi_code" );
memory_cycle_ok($label_data);
memory_cycle_ok($label);

my $annotation = $label_data->annotation->get_latest(3);
is ( $annotation->text, "Label Annotation", "annotation" );

memory_cycle_ok($label_data);
memory_cycle_ok($annotation);

$label = $label_data->get_by_gid('efdf3fe9-c293-4acd-b4b2-8d2a7d4f9592');
is ( $label->id, 3, "get label by gid" );

memory_cycle_ok($label_data);
memory_cycle_ok($label);

my $search = MusicBrainz::Server::Data::Search->new(c => $test->c);
my ($results, $hits) = $search->search("label", "Warp", 10);
is( $hits, 1, "Searching for Warp, 1 hit" );
is( scalar(@$results), 1, "Searching for Warp, 1 result" );
is( $results->[0]->position, 1 );
is( $results->[0]->entity->name, "Warp Records", "Found Warp Records");
is( $results->[0]->entity->sort_name, "Warp Records", "Found Warp Records");
memory_cycle_ok($label_data);
memory_cycle_ok($results);

my %names = $label_data->find_or_insert_names('Warp Records', 'RAM Records');
is(keys %names, 2);
is($names{'Warp Records'}, 1);
ok($names{'RAM Records'} > 1);

memory_cycle_ok($label_data);
memory_cycle_ok(\%names);

$test->c->sql->begin;
$test->c->raw_sql->begin;

$label = $label_data->insert({
        name => 'RAM Records',
        sort_name => 'RAM Records',
        type_id => 1,
        country_id => 1,
        ipi_code => '00407982340',
        end_date => { year => 2000, month => 05 }
    });
isa_ok($label, 'MusicBrainz::Server::Entity::Label');
ok($label->id > 1);
memory_cycle_ok($label_data);
memory_cycle_ok($label);

ok(!$test->c->model('Label')->in_use($label->id));
memory_cycle_ok($label_data);

$label = $label_data->get_by_id($label->id);
is($label->name, 'RAM Records', "name");
is($label->sort_name, 'RAM Records', "sort name");
is($label->type_id, 1, "type id");
is($label->country_id, 1, "country id");
ok(!$label->end_date->is_empty, "end date is not empty");
is($label->end_date->year, 2000, "end date, year");
is($label->end_date->month, 5, "end date, month");
is($label->ipi_code, '00407982340', "ipi_code");

$label_data->update($label->id, {
        sort_name => 'Records, RAM',
        begin_date => { year => 1990 },
        ipi_code => '00407982341',
        comment => 'Drum & bass label'
    });
memory_cycle_ok($label_data);

$label = $label_data->get_by_id($label->id);
is($label->name, 'RAM Records', "name hasn't changed");
is($label->sort_name, 'Records, RAM', "sort name updated");
is($label->comment, 'Drum & bass label', "comment updated");
ok(!$label->begin_date->is_empty, "begin date is not empty");
ok(!$label->end_date->is_empty, "end date is not empty");
is($label->begin_date->year, 1990, "begin date, year");
is($label->end_date->year, 2000, "end date, year");
is($label->end_date->month, 5, "end date, month");
is($label->ipi_code, '00407982341', "ipi_code updated");

$label_data->delete($label->id);
memory_cycle_ok($label_data);
$label = $label_data->get_by_id($label->id);
ok(!defined $label, "label deleted");

$label_data->merge(3, 2);
memory_cycle_ok($label_data);
$label = $label_data->get_by_id(2);
ok(!defined $label, "label merged");

$label = $label_data->get_by_id(3);
ok(defined $label, "label merged");

$test->c->raw_sql->commit;
$test->c->sql->commit;

};

1;
