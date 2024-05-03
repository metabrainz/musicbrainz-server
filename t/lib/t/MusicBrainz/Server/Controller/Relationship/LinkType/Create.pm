package t::MusicBrainz::Server::Controller::Relationship::LinkType::Create;
use strict;
use warnings;

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

test 'Creating new relationship types under /relationship/artist-artist as admin' => sub {
    my $test = shift;
    my $mech = $test->mech;

    my ($child_order, $name, $forward_lp, $reverse_lp, $long_lp, $entity0_cardinality, $entity1_cardinality) =
        (1, 'Link type', 'Forward', 'Reverse', 'Short', 1, 0, 0);

    $mech->get_ok('/relationships/artist-artist/create');
    html_ok($mech->content);
    my @edits = capture_edits {
        $mech->submit_form(
            with_fields => {
                'linktype.child_order' => $child_order,
                'linktype.name' => $name,
                'linktype.link_phrase' => $forward_lp,
                'linktype.reverse_link_phrase' => $reverse_lp,
                'linktype.long_link_phrase' => $long_lp,
                'linktype.entity0_cardinality' => $entity0_cardinality,
                'linktype.entity1_cardinality' => $entity1_cardinality,
            },
        );
        ok($mech->success);
    } $test->c;

    is(@edits, 1);
    isa_ok($edits[0], 'MusicBrainz::Server::Edit::Relationship::AddLinkType');
    my $data = $edits[0]->data;

    is($data->{$_->[0]}, $_->[1], 'Setting ' . $_->[0])
        for ( [ entity0_type => 'artist' ],
              [ entity1_type => 'artist' ],
              [ name => $name ],
              [ link_phrase => $forward_lp ],
              [ long_link_phrase => $long_lp ],
              [ reverse_link_phrase => $reverse_lp ],
              [ child_order => $child_order ],
              [ entity0_cardinality => $entity0_cardinality ],
              [ entity1_cardinality => $entity1_cardinality ] );
};

1;
