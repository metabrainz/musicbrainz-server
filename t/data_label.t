use strict;
use warnings;
use Test::More tests => 44;
use_ok 'MusicBrainz::Server::Data::Label';
use MusicBrainz::Server::Data::Search;

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;
use Sql;

my $c = MusicBrainz::Server::Context->new();
MusicBrainz::Server::Test->prepare_test_database($c);

my $label_data = MusicBrainz::Server::Data::Label->new(c => $c);

my $label = $label_data->get_by_id(2);
is ( $label->id, 2 );
is ( $label->gid, "46f0f4cd-8aab-4b33-b698-f459faf64190" );
is ( $label->name, "Warp Records" );
is ( $label->sort_name, "Warp Records" );
is ( $label->begin_date->year, 1989 );
is ( $label->begin_date->month, 2 );
is ( $label->begin_date->day, 3 );
is ( $label->end_date->year, 2008 );
is ( $label->end_date->month, 5 );
is ( $label->end_date->day, 19 );
is ( $label->edits_pending, 0 );
is ( $label->type_id, 1 );
is ( $label->label_code, 2070 );
is ( $label->format_label_code, 'LC-02070' );
is ( $label->comment, 'Sheffield based electronica label' );

my $annotation = $label_data->annotation->get_latest(2);
is ( $annotation->text, "Test annotation 2." );

$label = $label_data->get_by_gid('efdf3fe9-c293-4acd-b4b2-8d2a7d4f9592');
is ( $label->id, 2 );

my $search = MusicBrainz::Server::Data::Search->new(c => $c);
my ($results, $hits) = $search->search("label", "Warp", 10);
is( $hits, 1 );
is( scalar(@$results), 1 );
is( $results->[0]->position, 1 );
is( $results->[0]->entity->name, "Warp Records" );
is( $results->[0]->entity->sort_name, "Warp Records" );

my %names = $label_data->find_or_insert_names('Warp Records', 'RAM Records');
is(keys %names, 2);
is($names{'Warp Records'}, 2);
ok($names{'RAM Records'} > 2);

my $sql = Sql->new($c->mb->dbh);
$sql->Begin;
$label = $label_data->insert({
        name => 'RAM Records',
        sort_name => 'RAM Records',
        type => 1,
        country => 1,
        end_date => { year => 2000, month => 05 }
    });
isa_ok($label, 'MusicBrainz::Server::Entity::Label');
ok($label->id > 2);

$label = $label_data->get_by_id($label->id);
is($label->name, 'RAM Records');
is($label->sort_name, 'RAM Records');
is($label->type_id, 1);
is($label->country_id, 1);
ok(!$label->end_date->is_empty);
is($label->end_date->year, 2000);
is($label->end_date->month, 5);

$label_data->update($label, {
        sort_name => 'Records, RAM',
        begin_date => { year => 1990 },
        comment => 'Drum & bass label'
    });

$label = $label_data->get_by_id($label->id);
is($label->name, 'RAM Records');
is($label->sort_name, 'Records, RAM');
is($label->comment, 'Drum & bass label');
ok(!$label->begin_date->is_empty);
ok(!$label->end_date->is_empty);
is($label->begin_date->year, 1990);
is($label->end_date->year, 2000);
is($label->end_date->month, 5);

$label_data->delete($label);
$label = $label_data->get_by_id($label->id);
ok(!defined $label);
$sql->Commit;
