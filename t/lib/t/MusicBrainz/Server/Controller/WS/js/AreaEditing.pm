package t::MusicBrainz::Server::Controller::WS::js::AreaEditing;
use strict;
use warnings;

use JSON;
use Test::More;
use Test::Routine;
use MusicBrainz::Server::Constants qw(
    $EDIT_AREA_CREATE
    $EDIT_AREA_EDIT
    $EDIT_AREA_DELETE
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

test 'Creating areas is restricted to location editors' => forbidden_edit({
    edit_type => $EDIT_AREA_CREATE,
});

test 'Editing areas is restricted to location editors' => forbidden_edit({
    edit_type => $EDIT_AREA_EDIT,
});

test 'Removing areas is restricted to location editors' => forbidden_edit({
    edit_type => $EDIT_AREA_DELETE,
});

our @RELATIONSHIP_TESTS = (
    { types => 'area-area', link_type => 356 },
    { types => 'area-url', link_type => 355 },
);

for (@RELATIONSHIP_TESTS) {
    my $types = $_->{types};
    my $link_type = $_->{link_type};

    test "Adding $types relationships is restricted to location editors" => forbidden_edit({
        edit_type => $EDIT_RELATIONSHIP_CREATE,
        linkTypeID => $link_type,
    });

    test "Editing $types relationships is restricted to location editors" => forbidden_edit({
        edit_type => $EDIT_RELATIONSHIP_EDIT,
        linkTypeID => $link_type,
    });

    test "Removing $types relationships is restricted to location editors" => forbidden_edit({
        edit_type => $EDIT_RELATIONSHIP_DELETE,
        linkTypeID => $link_type,
    });
}

1;
