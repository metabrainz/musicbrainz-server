package t::MusicBrainz::Server::Edit::Work::AddAnnotation;
use Test::Routine;
use Test::More;

with 't::Context';

BEGIN { use MusicBrainz::Server::Edit::Work::AddAnnotation }

use MusicBrainz::Server::Constants qw( $EDIT_WORK_ADD_ANNOTATION );
use MusicBrainz::Server::Test;

test all => sub {

my $test = shift;
my $c = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+annotation');

my $edit = $c->model('Edit')->create(
    edit_type => $EDIT_WORK_ADD_ANNOTATION,
    editor_id => 1,

    entity => $c->model('Work')->get_by_id(1),
    text => 'Test annotation',
    changelog => 'A changelog',
);
isa_ok($edit, 'MusicBrainz::Server::Edit::Work::AddAnnotation');

my ($edits) = $c->model('Edit')->find({ work => 1 }, 10, 0);
is($edits->[0]->id, $edit->id);

$c->model('Edit')->load_all($edit);
is($edit->display_data->{work}{id}, 1);
is($edit->display_data->{changelog}, 'A changelog');

my $work = $c->model('Work')->get_by_id(1);

$c->model('Work')->annotation->load_latest($work);
my $annotation = $work->latest_annotation;
ok(defined $annotation);
is($annotation->editor_id, 1);
is($annotation->text, 'Test annotation');
is($annotation->changelog, 'A changelog');

my $annotation2 = $c->model('Work')->annotation->get_by_id($edit->annotation_id);
is_deeply($annotation, $annotation2);

};

1;
