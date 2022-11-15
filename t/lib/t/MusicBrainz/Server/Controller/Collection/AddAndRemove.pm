package t::MusicBrainz::Server::Controller::Collection::AddAndRemove;
use utf8;
use strict;
use warnings;

use Test::Routine;
use Test::More;

around run_test => sub {
    my ($orig, $test, @args) = @_;
    MusicBrainz::Server::Test->prepare_test_database($test->c, '+collection');

    $test->mech->get('/login');
    $test->mech->submit_form(
        with_fields => { username => 'editor1', password => 'pass' }
    );

    $test->$orig(@args);
};

with 't::Mechanize', 't::Context';

=head1 DESCRIPTION

This test checks whether adding entities to collections and removing them
works, and whether trying to add a non-existing entity fails gracefully.

=cut

test 'Can add release to collection from release page ' => sub {
    my $test = shift;
    my $mech = $test->mech;

    $mech->get_ok(
        '/release/c34c079d-374e-4436-9448-da92dedef3ce',
        'Fetched a release page',
    );
    $mech->text_contains(
        'Add to collection1',
        'The link to add the release to an existing collection is shown',
    );
    $mech->follow_link_ok(
        { text => 'Add to collection1' },
        'Could follow the "Add to collection1" link',
    );
    ok(
        $mech->uri =~ qr{/release/c34c079d-374e-4436-9448-da92dedef3ce},
        'We are still/again on the release page',
    );
    $mech->text_contains(
        'Remove from collection1',
        'The link to remove the release from the collection is now shown',
    );
    $mech->follow_link_ok(
        { text => 'Remove from collection1' },
        'Could follow the "Remove from collection1" link',
    );
    ok(
        $mech->uri =~ qr{/release/c34c079d-374e-4436-9448-da92dedef3ce},
        'We are still/again on the release page',
    );
    $mech->text_contains(
        'Add to collection1',
        'The link to add the release to the collection is shown once again',
    );
};

test 'Trying to add incorrect ids to collection fails gracefully' => sub {
    my $test = shift;
    my $mech = $test->mech;

    $mech->get(
        '/collection/f34c079d-374e-4436-9448-da92dedef3cd/collection_collaborator/add?release=hahahahano',
    );
    is(
        $mech->status,
        400,
        'Trying to add an invalid id to a collection fails',
    );
    $mech->text_contains(
        '“hahahahano” is not a valid row ID',
        'The expected error message is shown',
    );
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2022 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
