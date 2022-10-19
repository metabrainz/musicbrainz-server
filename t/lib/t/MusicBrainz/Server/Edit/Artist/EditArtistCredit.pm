package t::MusicBrainz::Server::Edit::Artist::EditArtistCredit;
use strict;
use warnings;

use Test::Routine;
use Test::More;

with 't::Edit';
with 't::Context';

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_ARTIST_EDITCREDIT $AUTO_EDITOR_FLAG );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

test all => sub {

my $test = shift;
my $c = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+decompose');

# Test creating the edit
my $ac = $c->model('ArtistCredit')->get_by_id(1);
my $edit = _create_edit($c, $ac);
isa_ok($edit, 'MusicBrainz::Server::Edit::Artist::EditArtistCredit');

my ($edits, $hits) = $c->model('Edit')->find({ artist => 5 }, 10, 0);
is($hits, 1);
is($edits->[0]->id, $edit->id);

($edits, $hits) = $c->model('Edit')->find({ artist => 6 }, 10, 0);
is($hits, 1);
is($edits->[0]->id, $edit->id);

($edits, $hits) = $c->model('Edit')->find({ artist => 7 }, 10, 0);
is($hits, 1);
is($edits->[0]->id, $edit->id);

my $artist = $c->model('Artist')->get_by_id(5);
ok(artist_credits_is($c, 1));
is($artist->edits_pending, 1);

# Test rejecting the edit
reject_edit($c, $edit);

$artist = $c->model('Artist')->get_by_id(5);
ok(artist_credits_is($c, 1));
is($artist->edits_pending, 0);

# Test accepting the edit
$ac = $c->model('ArtistCredit')->get_by_id(1);
$edit = _create_edit($c, $ac);

accept_edit($c, $edit);

ok(!artist_credits_is($c, 1));

};

test 'Not an auto-edit for auto-editors' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+decompose');
    my $ac = $c->model('ArtistCredit')->get_by_id(1);
    my $edit = _create_edit($c, $ac, privileges => $AUTO_EDITOR_FLAG);

    ok($edit->is_open);
};

sub _create_edit {
    my ($c, $ac, %opts) = @_;
    return $c->model('Edit')->create(
        edit_type => $EDIT_ARTIST_EDITCREDIT,
        editor_id => 1,
        %opts,
        to_edit => $ac,
        artist_credit => {
            names => [
                {
                    artist => { id => 6, name => 'Ed Rush' },
                    name => 'Ed Rush',
                    join_phrase => undef
                },
                {
                    artist => { id => 7, name => 'Optical' },
                    name => 'Optical',
                    join_phrase => ''
                }
            ]
        }
    );
}

sub artist_credits_is {
    my ($c, $id) = @_;
    my @ents = (
        $c->model('ReleaseGroup')->get_by_id(1),
        $c->model('Release')->get_by_id(1),
        $c->model('Recording')->get_by_id(1),
        $c->model('Track')->get_by_id(1)
    );

    return (grep { $_->artist_credit_id == $id } @ents) == @ents;
}

1;
