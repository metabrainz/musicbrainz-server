use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'MusicBrainz::Server::Edit::Release::AddAnnotation' }

use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_ADD_ANNOTATION );
use MusicBrainz::Server::Test;

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c, '+annotation');
MusicBrainz::Server::Test->prepare_raw_test_database($c);

my $edit = $c->model('Edit')->create(
    edit_type => $EDIT_RELEASE_ADD_ANNOTATION,
    editor_id => 1,

    entity_id => 1,
    text => 'Test annotation',
    changelog => 'A changelog',
);
isa_ok($edit, 'MusicBrainz::Server::Edit::Release::AddAnnotation');

my ($edits) = $c->model('Edit')->find({ release => 1 }, 10, 0);
is($edits->[0]->id, $edit->id);

$c->model('Edit')->load_all($edit);
is($edit->display_data->{release}->id, 1);
is($edit->display_data->{changelog}, 'A changelog');
is($edit->display_data->{annotation_id}, $edit->annotation_id);

my $release = $c->model('Release')->get_by_id(1);

$c->model('Release')->annotation->load_latest($release);
my $annotation = $release->latest_annotation;
ok(defined $annotation);
is($annotation->editor_id, 1);
is($annotation->text, 'Test annotation');
is($annotation->changelog, 'A changelog');

my $annotation2 = $c->model('Release')->annotation->get_by_id($edit->annotation_id);
is_deeply($annotation, $annotation2);

done_testing;
