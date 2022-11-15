package t::MusicBrainz::Server::Edit::ReleaseGroup::AddAnnotation;
use strict;
use warnings;

use Test::Routine;
use Test::More;

with 't::Context';

BEGIN { use MusicBrainz::Server::Edit::ReleaseGroup::AddAnnotation }

use MusicBrainz::Server::Constants qw( $EDIT_RELEASEGROUP_ADD_ANNOTATION );
use MusicBrainz::Server::Test;

test all => sub {

my $test = shift;
my $c = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+annotation');

my $edit = $c->model('Edit')->create(
    edit_type => $EDIT_RELEASEGROUP_ADD_ANNOTATION,
    editor_id => 1,

    entity => $c->model('ReleaseGroup')->get_by_id(1),
    text => 'Test annotation',
    changelog => 'A changelog',
);
isa_ok($edit, 'MusicBrainz::Server::Edit::ReleaseGroup::AddAnnotation');

my ($edits) = $c->model('Edit')->find({ release_group => 1 }, 10, 0);
is($edits->[0]->id, $edit->id);

$c->model('Edit')->load_all($edit);
is($edit->display_data->{release_group}{id}, 1);
is($edit->display_data->{changelog}, 'A changelog');

my $release_group = $c->model('ReleaseGroup')->get_by_id(1);

$c->model('ReleaseGroup')->annotation->load_latest($release_group);
my $annotation = $release_group->latest_annotation;
ok(defined $annotation);
is($annotation->editor_id, 1);
is($annotation->text, 'Test annotation');
is($annotation->changelog, 'A changelog');

my $annotation2 = $c->model('ReleaseGroup')->annotation->get_by_id($edit->annotation_id);
is_deeply($annotation, $annotation2);

};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
