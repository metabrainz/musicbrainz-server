package t::MusicBrainz::Server::Edit::Release::RemoveCoverArt;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use Test::Fatal;
use LWP::UserAgent::Mockable;

use FindBin '$Bin';

use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_ADD_COVER_ART $EDIT_RELEASE_REMOVE_COVER_ART );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

with 't::Context';

test 'Accepting removes the linked cover art' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+release');

    my $release = $c->model('Release')->get_by_id(1);
    create_add_edit($c, $release);

    my @artwork = get_artwork($c, $release);
    is(scalar @artwork, 1, 'artwork exists');

    ok !exception {
        my $edit = create_remove_edit($c, $release);
        accept_edit($c, $edit);
    };

    @artwork = get_artwork($c, $release);
    is(scalar @artwork, 0, 'artwork was removed');
};

test 'Rejecting does not make any changes' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+release');

    my $release = $c->model('Release')->get_by_id(1);

    ok !exception {
        create_add_edit($c, $release);
        my $edit = create_remove_edit($c, $release);
        reject_edit($c, $edit);
    };
};

sub get_artwork {
    my ($c, $release) = @_;
    return @{ $c->model('CoverArt')->find_by_release($release) };
}

sub create_add_edit {
    my ($c, $release) = @_;

    $c->model('Edit')->create(
        edit_type => $EDIT_RELEASE_ADD_COVER_ART,
        editor_id => 1,
        release => $release,
        cover_art_id => '1234',
        cover_art_types => [ ],
        cover_art_position => 1,
        cover_art_comment => '',
        cover_art_mime_type => 'image/jpeg',
    )->accept;
}

sub create_remove_edit {
    my ($c, $release) = @_;

    my @artwork = get_artwork($c, $release);

    $c->model('Edit')->create(
        edit_type => $EDIT_RELEASE_REMOVE_COVER_ART,
        editor_id => 1,
        release => $release,
        to_delete => $artwork[0],
        cover_art_type => 'cover',
        cover_art_page => 2,
    );
}

1;
