package t::MusicBrainz::Server::Controller::WS::js::InstrumentEditing;
use strict;
use warnings;

use JSON;
use Test::More;
use Test::Routine;
use MusicBrainz::Server::Constants qw(
    $EDIT_INSTRUMENT_CREATE
    $EDIT_INSTRUMENT_EDIT
    $EDIT_INSTRUMENT_DELETE
    $EDIT_RELATIONSHIP_CREATE
    $EDIT_RELATIONSHIP_EDIT
    $EDIT_RELATIONSHIP_DELETE
);
use MusicBrainz::Server::Test qw( capture_edits post_json );

with 't::Mechanize', 't::Context';

sub prepare_test_database {
    my $c = shift;

    $c->sql->do(q{
        INSERT INTO editor (id, name, password, privs, email, website, bio, email_confirm_date, member_since, ha1)
        VALUES (1, 'editor', '{CLEARTEXT}password', 0, 'noreply@example.com', '', '', '1999-09-09', '1999-09-09', '3a115bc4f05ea9856bd4611b75c80bca');
    });
}

sub forbidden_edit {
    my ($edit) = @_;

    return sub {
        my ($test) = @_;

        prepare_test_database($test->c);

        $test->mech->get_ok('/login');
        $test->mech->submit_form(with_fields => { username => 'editor', password => 'password' });

        my @edits = capture_edits {
            post_json($test->mech, '/ws/js/edit/create', encode_json({ edits => [$edit] }));
        } $test->c;

        like($test->mech->status, qr/^40[03]$/);
        is(scalar(@edits), 0);
    };
}

test 'Creating instruments is restricted to relationship editors' => forbidden_edit({
    edit_type => $EDIT_INSTRUMENT_CREATE,
});

test 'Editing instruments is restricted to relationship editors' => forbidden_edit({
    edit_type => $EDIT_INSTRUMENT_EDIT,
});

test 'Removing instruments is restricted to relationship editors' => forbidden_edit({
    edit_type => $EDIT_INSTRUMENT_DELETE,
});

our @RELATIONSHIP_TESTS = (
    { types => 'area-instrument', link_type => 752 },
    { types => 'instrument-instrument', link_type => 739 },
    { types => 'instrument-url', link_type => 731 },
);

for (@RELATIONSHIP_TESTS) {
    my $types = $_->{types};
    my $link_type = $_->{link_type};

    test "Adding $types relationships is restricted to relationship editors" => forbidden_edit({
        edit_type => $EDIT_RELATIONSHIP_CREATE,
        linkTypeID => $link_type,
    });

    test "Editing $types relationships is restricted to relationship editors" => forbidden_edit({
        edit_type => $EDIT_RELATIONSHIP_EDIT,
        linkTypeID => $link_type,
    });

    test "Removing $types relationships is restricted to relationship editors" => forbidden_edit({
        edit_type => $EDIT_RELATIONSHIP_DELETE,
        linkTypeID => $link_type,
    });
}

1;
