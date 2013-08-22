package t::MusicBrainz::Server::Controller::Relationship::LinkType::Edit;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( capture_edits html_ok );

around run_test => sub {
    my ($orig, $test, @args) = @_;
    $test->c->sql->do(<<'EOSQL');
INSERT INTO editor (id, name, password, email, privs, ha1, email_confirm_date)
VALUES (1, 'editor1', '{CLEARTEXT}pass', 'editor1@example.com', 255, '16a4862191803cb596ee4b16802bb7ee', now())
EOSQL

    $test->mech->get('/login');
    $test->mech->submit_form( with_fields => { username => 'editor1', password => 'pass' } );

    $test->$orig(@args);
};

with 't::Mechanize', 't::Context';

test 'Editing an artist-artist link type' => sub {
    my $test = shift;
    my $mech = $test->mech;

    $test->c->sql->do(<<'EOSQL');
INSERT INTO link_type (id, gid, entity_type0, entity_type1, name,
    link_phrase, reverse_link_phrase, long_link_phrase)
  VALUES (1, '77a0f1d3-f9ec-4055-a6e7-24d7258c21f7', 'artist', 'artist',
          'member of band', 'lt', 'r', 's');
EOSQL

    my $new_name = 'Renamed';

    $mech->get_ok('/relationship/77a0f1d3-f9ec-4055-a6e7-24d7258c21f7/edit');
    my @edits = capture_edits {
        my $response = $mech->submit_form(
            with_fields => {
                'linktype.name' => $new_name,
            }
        );
        ok($mech->success);
    } $test->c;

    is(@edits, 1);
    isa_ok($edits[0], 'MusicBrainz::Server::Edit::Relationship::EditLinkType');
    my $data = $edits[0]->data;

    is($data->{link_id}, 1, 'edits correct link type');
    is($data->{new}{name}, $new_name, 'Sets new name correctly');
};

1;
