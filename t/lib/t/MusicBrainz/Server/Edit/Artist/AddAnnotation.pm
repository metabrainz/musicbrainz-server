package t::MusicBrainz::Server::Edit::Artist::AddAnnotation;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use Test::Fatal;

with 't::Context';

BEGIN { use MusicBrainz::Server::Edit::Artist::AddAnnotation }

use MusicBrainz::Server::Constants qw( $EDIT_ARTIST_ADD_ANNOTATION );
use MusicBrainz::Server::Test qw( capture_edits );

test 'Entering add annotation edit works as expected' => sub {

    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+annotation');

    my $edit = create_edit($c, 'Test annotation', 'A changelog');
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

test 'MBS-12556: Cannot create edit unless annotation has changed' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+annotation');

    my $text = 'Test annotation';

    my @edits = capture_edits { create_edit($c, $text) } $test->c;

    is(@edits, 1, 'We entered an edit adding an annotation to the artist');

    isa_ok($edits[0], 'MusicBrainz::Server::Edit::Artist::AddAnnotation');

    my $exception = exception { create_edit($c, $text, 'A changelog') };
    ok(
        defined $exception,
        'We tried to add the same annotation text again with a changelog and got an exception',
    );
    isa_ok($exception, 'MusicBrainz::Server::Edit::Exceptions::NoChanges');
};

sub create_edit {
    my ($c, $text, $changelog) = @_;
    $changelog //= '';
    return $c->model('Edit')->create(
        edit_type => $EDIT_ARTIST_ADD_ANNOTATION,
        editor_id => 1,
        entity => $c->model('Artist')->get_by_id(1),
        text => $text,
        changelog => $changelog,
    );
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
