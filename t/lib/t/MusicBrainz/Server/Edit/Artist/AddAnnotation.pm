package t::MusicBrainz::Server::Edit::Artist::AddAnnotation;
use Test::Routine;
use Test::More;

with 't::Context';

BEGIN { use MusicBrainz::Server::Edit::Artist::AddAnnotation }

use MusicBrainz::Server::Constants qw( $EDIT_ARTIST_ADD_ANNOTATION );
use MusicBrainz::Server::Test;

test all => sub {

my $test = shift;
my $c = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+annotation');

my $edit = $c->model('Edit')->create(
    edit_type => $EDIT_ARTIST_ADD_ANNOTATION,
    editor_id => 1,

    entity => $c->model('Artist')->get_by_id(1),
    text => 'Test annotation',
    changelog => 'A changelog',
);
isa_ok($edit, 'MusicBrainz::Server::Edit::Artist::AddAnnotation');

my ($edits) = $c->model('Edit')->find({ artist => 1 }, 10, 0);
is($edits->[0]->id, $edit->id);

$c->model('Edit')->load_all($edit);
is($edit->display_data->{artist}{id}, 1);
is($edit->display_data->{changelog}, 'A changelog');

my $artist = $c->model('Artist')->get_by_id(1);

$c->model('Artist')->annotation->load_latest($artist);
my $annotation = $artist->latest_annotation;
ok(defined $annotation);
is($annotation->editor_id, 1);
is($annotation->text, 'Test annotation');
is($annotation->changelog, 'A changelog');

my $annotation2 = $c->model('Artist')->annotation->get_by_id($edit->annotation_id);
is_deeply($annotation, $annotation2);

};

1;
