package t::MusicBrainz::Server::Controller::Relationship::LinkType::Edit;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( capture_edits html_ok );

around run_test => sub {
    my ($orig, $test, @args) = @_;
    $test->c->sql->do(<<~'SQL');
        INSERT INTO editor (id, name, password, email, privs, ha1, email_confirm_date)
            VALUES (1, 'editor1', '{CLEARTEXT}pass', 'editor1@example.com', 255, '16a4862191803cb596ee4b16802bb7ee', now())
        SQL

    $test->mech->get('/login');
    $test->mech->submit_form( with_fields => { username => 'editor1', password => 'pass' } );

    $test->$orig(@args);
};

with 't::Mechanize', 't::Context';

test 'Editing an artist-artist link type' => sub {
    my $test = shift;
    my $mech = $test->mech;

    my $new_name = 'Renamed';

    $mech->get_ok('/relationship/5be4c609-9afa-4ea0-910b-12ffb71e3821/edit');
    html_ok($mech->content);
    my @edits = capture_edits {
        $mech->submit_form(
            with_fields => {
                'linktype.name' => $new_name,
            }
        );
        ok($mech->success);
    } $test->c;

    is(@edits, 1);
    isa_ok($edits[0], 'MusicBrainz::Server::Edit::Relationship::EditLinkType');
    my $data = $edits[0]->data;

    is($data->{link_id}, 103, 'edits correct link type');
    is($data->{new}{name}, $new_name, 'Sets new name correctly');
};

1;
