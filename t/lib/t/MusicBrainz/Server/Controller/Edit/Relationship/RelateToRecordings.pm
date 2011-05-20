package t::MusicBrainz::Server::Controller::Edit::Relationship::RelateToRecordings;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok capture_edits );

with 't::Context', 't::Mechanize';

test 'Can enter a batch relate to recordings edit' => sub {
    my $test = shift;
    my ($c, $mech) = ($test->c, $test->mech);

    MusicBrainz::Server::Test->prepare_test_database($c, '+tracklist');
    MusicBrainz::Server::Test->prepare_test_database($c, <<'EOSQL');
INSERT INTO link_type (id, child_order, gid, entity_type0, entity_type1, name, link_phrase, short_link_phrase,
                       reverse_link_phrase)
    VALUES (122, 0, 'f8673e29-02a5-47b7-af61-dd4519328dd0', 'artist', 'recording', 'performance', 'performance', 'performance', 'performance');

INSERT INTO
    editor ( id, name, password, privs, email, website, bio,
             email_confirm_date, member_since, last_login_date, edits_accepted, edits_rejected,
             auto_edits_accepted, edits_failed)
    VALUES ( 1, 'new_editor', 'password', 0, 'test@editor.org', 'http://musicbrainz.org',
             'biography', '2005-10-20', '1989-07-23', '2009-01-01', 12, 2, 59, 9 );
EOSQL

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    my $release = 'f205627f-b70a-409d-adbe-66289b614e80';
    my $artist  = '945c079d-374e-4436-9448-da92dedef3cf';

    $mech->get_ok("/edit/relationship/create-recordings?release=$release&type=artist&gid=$artist");
    html_ok($mech->content);

    my @recording_ids = (1, 2, 3, 10, 11, 13);
    my @edits = capture_edits {
        $mech->submit_form(
            with_fields => {
                recording_id => [ \@recording_ids, 1 ],# Set 'recording_id' field 1 to an array ref, bit weird...
                'ar.link_type_id' => 122
            }
        );
    } $c;

    is(@edits => 6);
    for my $recording_id (@recording_ids) {
        subtest "Check submission for recording $recording_id" => sub {
            my ($edit) = my @possible_edits = grep { $_->data->{entity1}{id} == $recording_id } @edits;
            is(@possible_edits, 1, "1 edit for $recording_id");

            is($edit->data->{entity0}{id}, 1, 'relates to artist 1');
            is($edit->data->{entity1}{id}, $recording_id, "relates to recording $recording_id");
            is($edit->data->{link_type}{id}, 122, 'uses link type 1');
            is_deeply($edit->data->{attributes}, [], 'has no attributes');
            is_deeply($edit->data->{begin_date}, { year => undef, month => undef, day => undef },
                      'has no begin date');
            is_deeply($edit->data->{end_date}, { year => undef, month => undef, day => undef },
                      'has no end date');
            is($edit->data->{type0}, 'artist', 'type 0 is artist');
            is($edit->data->{type1}, 'recording', 'type 1 is recording');
        };
    }
};

1;
