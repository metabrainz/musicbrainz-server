package t::MusicBrainz::Server::Edit::Medium::AddDiscID;
use Test::Routine;
use Test::More;
use Test::Fatal;

around run_test => sub {
    my ($orig, $test) = splice(@_, 0, 2);
    MusicBrainz::Server::Test->prepare_test_database($test->c, '+edit_medium');
    MusicBrainz::Server::Test->prepare_test_database($test->c, <<'EOSQL');
INSERT INTO track (id, name, tracklist, recording, artist_credit, position)
    VALUES (1, 1, 1, 1, 1, 1), (2, 1, 1, 1, 1, 2);
EOSQL
    $test->_clear_edit;
    $test->$orig(@_);
};

with 't::Edit';
with 't::Context';

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_MEDIUM_ADD_DISCID );
use MusicBrainz::Server::Types qw( $STATUS_APPLIED $STATUS_FAILEDVOTE);
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

has edit => (
    is => 'ro',
    lazy => 1,
    clearer => '_clear_edit',
    builder => '_build_edit'
);

sub create_edit { shift->edit }

test 'Entering adds the disc ID' => sub {
    my $test = shift;
    $test->create_edit;

    is_cdtoc_count($test->c, 1, 1);
    is($test->edit->status, $STATUS_APPLIED);
};

test 'Entering a CDTOC for a medium with no track times sets them' => sub {
    my $test = shift;
    $test->create_edit;

    my $tracklist = $test->c->model('Tracklist')->get_by_id(100);
    $test->c->model('Track')->load_for_tracklists($tracklist);
    is($tracklist->tracks->[0]->length, 290240);
    is($tracklist->tracks->[1]->length, 3183066);
};

test 'Entering a CDTOC for a medium with some track times does not set them' => sub {
    my $test = shift;
    $test->c->sql->do('UPDATE track SET length = 19999 WHERE id = 1');

    $test->create_edit;

    my $tracklist = $test->c->model('Tracklist')->get_by_id(1);
    $test->c->model('Track')->load_for_tracklists($tracklist);
    is($tracklist->tracks->[0]->length, 19999);
    is($tracklist->tracks->[1]->length, undef);
};

sub _build_edit {
    my ($test) = @_;
    my $release = $test->c->model('Release')->get_by_id(1);
    $test->c->model('Edit')->create(
        edit_type => $EDIT_MEDIUM_ADD_DISCID,
        editor_id => 1,
        release => $release,
        medium_id => 1,
        cdtoc => '1 2 260648 150 21918'
    );
}

sub is_cdtoc_count {
    my ($c, $medium_id, $count) = @_;
    my $medium = $c->model('Medium')->get_by_id($medium_id);
    $c->model('MediumCDTOC')->load_for_mediums($medium);
    is($medium->all_cdtocs => $count);
}

1;
