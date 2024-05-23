package t::MusicBrainz::Server::Edit::Release::AddCoverArt;
use strict;
use warnings;
use utf8;

use Test::Routine;
use Test::More;

use FindBin '$Bin';

use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_ADD_COVER_ART );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

with 't::Context';

test 'Accepting Add Cover Art edit' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+release');

    my $release = $c->model('Release')->get_by_id(1);
    my $edit = create_edit($c, $release);
    my @artwork = @{ $c->model('CoverArt')->find_by_release($release) };

    ok(
        scalar @artwork == 1 &&
            $artwork[0]->id == 1234 &&
            !$artwork[0]->approved,
        'artwork is added, but not approved',
    );

    accept_edit($c, $edit);

    @artwork = @{ $c->model('CoverArt')->find_by_release($release) };
    ok(
        scalar @artwork == 1 &&
            $artwork[0]->id == 1234 &&
            $artwork[0]->approved,
        'artwork is approved after edit is accepted',
    );

    my ($edits, undef) = $c->model('Edit')->find({ release => 1 }, 1, 0);
    ok(
        scalar @$edits && $edits->[0]->id == $edit->id,
        'edit is in the release’s edit history',
    );
};

test 'Rejecting cleans up pending artwork' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+release');

    my $release = $c->model('Release')->get_by_id(1);
    my $edit = create_edit($c, $release);
    my @artwork = @{ $c->model('CoverArt')->find_by_release($release) };

    ok(
        scalar @artwork == 1 &&
            $artwork[0]->id == 1234 &&
            !$artwork[0]->approved,
        'artwork is added, but not approved',
    );

    reject_edit($c, $edit);

    @artwork = @{ $c->model('CoverArt')->find_by_release($release) };
    is(scalar @artwork, 0, 'artwork is removed after edit is rejected');

    my ($edits, undef) = $c->model('Edit')->find({ release => 1 }, 1, 0);
    ok(
        scalar @$edits && $edits->[0]->id == $edit->id,
        'edit is in the release’s edit history',
    );
};

sub create_edit {
    my ($c, $release) = @_;
    $c->model('Edit')->create(
        edit_type => $EDIT_RELEASE_ADD_COVER_ART,
        editor_id => 1,
        release => $release,
        cover_art_id => '1234',
        cover_art_types => [ 1 ],
        cover_art_position => 1,
        cover_art_comment => '',
        cover_art_mime_type => 'image/jpeg',
    );
}

1;
