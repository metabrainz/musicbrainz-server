package t::MusicBrainz::Server::Controller::Relationship::LinkType::Create;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( capture_edits html_ok );

around run_test => sub {
    my ($orig, $test, @args) = @_;
    $test->c->sql->do(<<'EOSQL');
INSERT INTO editor (id, name, password, email, privs, ha1) VALUES (1, 'editor1', '{CLEARTEXT}pass', 'editor1@example.com', 255, '16a4862191803cb596ee4b16802bb7ee')
EOSQL

    $test->mech->get('/login');
    $test->mech->submit_form( with_fields => { username => 'editor1', password => 'pass' } );

    $test->$orig(@args);
};

with 't::Mechanize', 't::Context';

test 'Creating new relationship types under /relationship/artist-artist as admin' => sub {
    my $test = shift;
    my $mech = $test->mech;

    my ($child_order, $name, $forward_lp, $reverse_lp, $long_lp, $priority) =
        (1, 'Link type', 'Forward', 'Reverse', 'Short', 1);

    $mech->get_ok('/relationships/artist-artist/create');
    my @edits = capture_edits {
        my $response = $mech->submit_form(
            with_fields => {
                'linktype.child_order' => $child_order,
                'linktype.name' => $child_order,
                'linktype.link_phrase' => $forward_lp,
                'linktype.reverse_link_phrase' => $reverse_lp,
                'linktype.long_link_phrase' => $long_lp,
                'linktype.priority' => $priority
            }
        );
        ok($mech->success);
    } $test->c;

    is(@edits, 1);
    isa_ok($edits[0], 'MusicBrainz::Server::Edit::Relationship::AddLinkType');
    my $data = $edits[0]->data;

    is($data->{$_->[0]}, $_->[1], 'Setting ' . $_->[0])
        for ( [ entity0_type => 'artist' ],
              [ entity1_type => 'artist' ],
              [ link_phrase => $forward_lp ],
              [ long_link_phrase => $long_lp ],
              [ reverse_link_phrase => $reverse_lp ],
              [ child_order => $child_order ],
              [ priority => $priority ] );
};

1;
