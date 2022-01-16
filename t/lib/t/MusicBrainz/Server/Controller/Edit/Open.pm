package t::MusicBrainz::Server::Controller::Edit::Open;
use Test::Routine;

use MusicBrainz::Server::Constants qw(
    $EDIT_ARTIST_EDIT
    $UNTRUSTED_FLAG
);
use MusicBrainz::Server::Test qw( accept_edit html_ok );

with 't::Mechanize', 't::Context';

test '/edit/open shows open edits' => sub {
    my $test = shift;
    my $edit = prepare($test);

    $test->mech->get_ok('/edit/open', 'fetch open edits');

    $test->mech->content_contains('/edit/' . $edit->id);
};

test '/edit/open does not show accepted edits' => sub {
    my $test = shift;
    my $edit = prepare($test);

    accept_edit($test->c, $edit);

    $test->mech->get_ok('/edit/open', 'fetch open edits');
    html_ok($test->mech->content);
    $test->mech->content_lacks('/edit/' . $edit->id);
};

test '/edit/open does not show own edits' => sub {
    my $test = shift;
    my $edit = prepare($test);

    $test->mech->get_ok('/login');
    $test->mech->submit_form( with_fields => {
        username => 'editor1',
        password => 'pass',
    } );

    $test->mech->get_ok('/edit/open', 'fetch open edits');
    html_ok($test->mech->content);
    $test->mech->content_lacks('/edit/' . $edit->id);
};

sub prepare {
    my $test = shift;
    my $c = $test->c;

    $c->sql->do(<<~'SQL');
        INSERT INTO artist (id, gid, name, sort_name)
            VALUES (1, 'e69a970a-e916-11e0-a751-00508db50876', 'artist', 'artist');
        INSERT INTO editor (id, name, password, email, ha1, email_confirm_date)
            VALUES (1, 'editor1', '{CLEARTEXT}pass', 'editor1@example.com', '16a4862191803cb596ee4b16802bb7ee', now()),
                   (2, 'editor2', '{CLEARTEXT}pass', 'editor2@example.com', 'ba025a52cc5ff57d5d10f31874a83de6', now())
        SQL

    my $edit = $test->c->model('Edit')->create(
        editor_id => 1,
        edit_type => $EDIT_ARTIST_EDIT,
        to_edit => $c->model('Artist')->get_by_id(1),
        comment => 'Changed comment',
        ipi_codes => [],
        isni_codes => [],
        privileges => $UNTRUSTED_FLAG,
    );

    return $edit;
}

1;
