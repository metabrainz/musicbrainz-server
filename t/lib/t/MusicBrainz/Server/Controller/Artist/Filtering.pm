package t::MusicBrainz::Server::Controller::Artist::Filtering;
use utf8;
use strict;
use warnings;

use Test::Routine;
use MusicBrainz::Server::Test qw( test_xpath_html );

with 't::Mechanize', 't::Context';

=head2 Test description

This test checks whether filtering works for different entity lists
in artist pages (RGs, recordings, works).

=cut

test 'Overview (release group) filtering' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+filtering');

    $mech->get_ok(
        '/artist/af4c43d3-c0e0-421e-ac64-000329af0435',
        'Fetched artist overview page',
    );

    my $tx = test_xpath_html($mech->content);
    $tx->is(
        'count(//table[@class="tbl release-group-list"]/tbody/tr)',
        '6',
        'There are six entries in the unfiltered release group tables',
    );

    $mech->get_ok(
        '/artist/af4c43d3-c0e0-421e-ac64-000329af0435?filter.name=Symphony',
        'Fetched artist overview page with name filter "Symphony"',
    );

    $tx = test_xpath_html($mech->content);
    $tx->is(
        'count(//table[@class="tbl release-group-list"]/tbody/tr)',
        '2',
        'There are two entries in the release group tables after filtering by name',
    );
    $tx->is(
        '//table[@class="tbl release-group-list"]/tbody/tr[1]/td[2]',
        'Concerto for Orchestra / Symphony no. 3',
        'The first entry is named "Concerto for Orchestra / Symphony no. 3"',
    );

    $mech->get_ok(
        '/artist/af4c43d3-c0e0-421e-ac64-000329af0435?filter.artist_credit_id=3401',
        'Fetched artist overview page with artist credit filter',
    );

    $tx = test_xpath_html($mech->content);
    $tx->is(
        'count(//table[@class="tbl release-group-list"]/tbody/tr)',
        '1',
        'There is one entry in the release group tables after filtering by credit',
    );
    $tx->is(
        '//table[@class="tbl release-group-list"]/tbody/tr[1]/td[2]',
        'Piano Concerto / Symphony no. 2',
        'The entry is named "Piano Concerto / Symphony no. 2"',
    );

    $mech->get_ok(
        '/artist/af4c43d3-c0e0-421e-ac64-000329af0435?filter.type_id=2',
        'Fetched artist overview page with type filter "Single"',
    );

    $tx = test_xpath_html($mech->content);
    $tx->is(
        'count(//table[@class="tbl release-group-list"]/tbody/tr)',
        '1',
        'There is one entry in the release group tables after filtering by "Single" type',
    );
    $tx->is(
        '//table[@class="tbl release-group-list"]/tbody/tr[1]/td[2]',
        'Jeux vénetiens',
        'The entry is named "Jeux vénetiens"',
    );

    $mech->get_ok(
        '/artist/af4c43d3-c0e0-421e-ac64-000329af0435?filter.type_id=-1',
        'Fetched artist overview page with type filter "[none]"',
    );

    $tx = test_xpath_html($mech->content);
    $tx->is(
        'count(//table[@class="tbl release-group-list"]/tbody/tr)',
        '1',
        'There is one entry in the release group tables after filtering by no type',
    );
    $tx->is(
        '//table[@class="tbl release-group-list"]/tbody/tr[1]/td[2]',
        'String Quartet',
        'The entry is named "String Quartet"',
    );

    $mech->get_ok(
        '/artist/af4c43d3-c0e0-421e-ac64-000329af0435?filter.secondary_type_id=6',
        'Fetched artist overview page with secondary type filter "Live"',
    );

    $tx = test_xpath_html($mech->content);
    $tx->is(
        'count(//table[@class="tbl release-group-list"]/tbody/tr)',
        '2',
        'There are two entries in the release group tables after filtering by "Live" secondary type',
    );
    $tx->is(
        'count(//table[@class="tbl release-group-list"])',
        '2',
        'There are two tables present, for albums and singles',
    );

    $mech->get_ok(
        '/artist/af4c43d3-c0e0-421e-ac64-000329af0435?filter.type_id=1&filter.secondary_type_id=6',
        'Fetched artist overview page with type filter "Album" and secondary type filter "Live"',
    );

    $tx = test_xpath_html($mech->content);
    $tx->is(
        'count(//table[@class="tbl release-group-list"]/tbody/tr)',
        '1',
        'There is one entry in the release group tables after filtering by both "Album" and "Live"',
    );
    $tx->is(
        '//table[@class="tbl release-group-list"]/tbody/tr[1]/td[2]',
        'Lutosławski',
        'The entry is named "Lutosławski"',
    );

    $mech->get_ok(
        '/artist/af4c43d3-c0e0-421e-ac64-000329af0435?filter.type_id=1&filter.secondary_type_id=-1',
        'Fetched artist overview page with type filter "Album" and secondary type filter "[none]"',
    );

    $tx = test_xpath_html($mech->content);
    $tx->is(
        'count(//table[@class="tbl release-group-list"]/tbody/tr)',
        '3',
        'There are three entries in the release group tables after filtering by album with no secondary type',
    );

    $mech->get_ok(
        '/artist/af4c43d3-c0e0-421e-ac64-000329af0435?filter.type_id=2&filter.name=Symphony',
        'Fetched artist overview page with name filter "Symphony" and type filter "Single"',
    );

    $mech->content_contains(
        'No release groups found that match this search.',
        'The "no results" message is shown',
    );
};

test 'Event page filtering' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+filtering');

    $mech->get_ok(
        '/artist/dea28aa9-1086-4ffa-8739-0ccc759de1ce/events',
        'Fetched artist events page',
    );

    my $tx = test_xpath_html($mech->content);
    $tx->is(
        'count(//table[@class="tbl"]/tbody/tr)',
        '4',
        'There are four entries in the unfiltered event table',
    );

    $mech->get_ok(
        '/artist/dea28aa9-1086-4ffa-8739-0ccc759de1ce/events?filter.name=Schnittke',
        'Fetched artist events page with name filter "Schnittke"',
    );

    $tx = test_xpath_html($mech->content);
    $tx->is(
        'count(//table[@class="tbl"]/tbody/tr)',
        '1',
        'There is one entry in the event table after filtering by name',
    );
    $tx->is(
        '//table[@class="tbl"]/tbody/tr/td[1]',
        'Berliner Philharmoniker plays Schnittke and Shostakovich',
        'The entry is named "Berliner Philharmoniker plays Schnittke and Shostakovich"',
    );

    $mech->get_ok(
        '/artist/dea28aa9-1086-4ffa-8739-0ccc759de1ce/events?filter.type_id=1',
        'Fetched artist events page with type filter "Concert"',
    );

    $tx = test_xpath_html($mech->content);
    $tx->is(
        'count(//table[@class="tbl"]/tbody/tr)',
        '3',
        'There are three entries in the event table after filtering by "Concert" type',
    );

    $mech->get_ok(
        '/artist/dea28aa9-1086-4ffa-8739-0ccc759de1ce/events?filter.type_id=-1',
        'Fetched artist events page with type filter "[none]"',
    );

    $tx = test_xpath_html($mech->content);
    $tx->is(
        'count(//table[@class="tbl"]/tbody/tr)',
        '1',
        'There is one entry in the event table after filtering by no type',
    );
    $tx->is(
        '//table[@class="tbl"]/tbody/tr/td[1]',
        'Uncertain',
        'The entry is named "Uncertain"',
    );

    $mech->get_ok(
        '/artist/dea28aa9-1086-4ffa-8739-0ccc759de1ce/events?filter.setlist=world+premiere',
        'Fetched artist events page with setlist filter "world premiere"',
    );

    $tx = test_xpath_html($mech->content);
    $tx->is(
        'count(//table[@class="tbl"]/tbody/tr)',
        '2',
        'There are two entries in the event table after filtering by setlist',
    );
    $tx->is(
        '//table[@class="tbl"]/tbody/tr[1]/td[1]',
        '[concert]',
        'The first entry is named [concert]',
    );
};

test 'Recording page filtering' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+filtering');

    $mech->get_ok(
        '/artist/af4c43d3-c0e0-421e-ac64-000329af0435/recordings',
        'Fetched artist recordings page',
    );

    my $tx = test_xpath_html($mech->content);
    $tx->is(
        'count(//table[@class="tbl"]/tbody/tr)',
        '4',
        'There are four entries in the unfiltered recording table',
    );

    $mech->get_ok(
        '/artist/af4c43d3-c0e0-421e-ac64-000329af0435/recordings?filter.name=Symphony',
        'Fetched artist recordings page with name filter "Symphony"',
    );

    $tx = test_xpath_html($mech->content);
    $tx->is(
        'count(//table[@class="tbl"]/tbody/tr)',
        '1',
        'There is one entry in the recording table after filtering by name',
    );
    $tx->is(
        '//table[@class="tbl"]/tbody/tr/td[1]',
        'Symphony no. 3',
        'The entry is named "Symphony no. 3"',
    );

    $mech->get_ok(
        '/artist/af4c43d3-c0e0-421e-ac64-000329af0435/recordings?filter.artist_credit_id=3402',
        'Fetched artist recordings page with artist credit filter',
    );

    $tx = test_xpath_html($mech->content);
    $tx->is(
        'count(//table[@class="tbl"]/tbody/tr)',
        '2',
        'There are two entries in the recording table after filtering by credit',
    );
    $tx->is(
        '//table[@class="tbl"]/tbody/tr[1]/td[2]',
        'Sinfonia Varsovia, Witold Lutosławski',
        'The first has the expected artist credit"',
    );
};

test 'Work page filtering' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+filtering');

    $mech->get_ok(
        '/artist/af4c43d3-c0e0-421e-ac64-000329af0435/works',
        'Fetched artist works page',
    );

    my $tx = test_xpath_html($mech->content);
    $tx->is(
        'count(//table[@class="tbl"]/tbody/tr)',
        '5',
        'There are five entries in the unfiltered work table',
    );

    $mech->get_ok(
        '/artist/af4c43d3-c0e0-421e-ac64-000329af0435/works?filter.role_type=1',
        'Fetched artist works page with "as performer" filter',
    );

    $tx = test_xpath_html($mech->content);
    $tx->is(
        'count(//table[@class="tbl"]/tbody/tr)',
        '3',
        'There are three entries in the "as performer" work table (even though one work was performed twice)',
    );
    $mech->content_lacks('Mini Overture', 'Not performed work is not shown');

    $mech->get_ok(
        '/artist/af4c43d3-c0e0-421e-ac64-000329af0435/works?filter.role_type=2',
        'Fetched artist works page with "as writer" filter',
    );

    $tx = test_xpath_html($mech->content);
    $tx->is(
        'count(//table[@class="tbl"]/tbody/tr)',
        '4',
        'There are four entries in the "as writer" work table',
    );
    $mech->content_lacks(
        'Brandenburgisches Konzert',
        'Not written work is not shown',
    );

    $mech->get_ok(
        '/artist/af4c43d3-c0e0-421e-ac64-000329af0435/works?filter.type_id=16',
        'Fetched artist works page with type filter "Symphony"',
    );

    $tx = test_xpath_html($mech->content);
    $tx->is(
        'count(//table[@class="tbl"]/tbody/tr)',
        '2',
        'There are two entries in the work table after filtering by "Symphony" type',
    );

    $mech->get_ok(
        '/artist/af4c43d3-c0e0-421e-ac64-000329af0435/works?filter.type_id=-1',
        'Fetched artist works page with type filter "[none]"',
    );

    $tx = test_xpath_html($mech->content);
    $tx->is(
        'count(//table[@class="tbl"]/tbody/tr)',
        '1',
        'There is one entry in the work table after filtering by no type',
    );
    $tx->is(
        '//table[@class="tbl"]/tbody/tr/td[1]',
        'Interlude',
        'The entry is named "Interlude"',
    );

    $mech->get_ok(
        '/artist/af4c43d3-c0e0-421e-ac64-000329af0435/works?filter.name=Interlude',
        'Fetched artist works page with name filter "Interlude"',
    );

    $tx = test_xpath_html($mech->content);
    $tx->is(
        'count(//table[@class="tbl"]/tbody/tr)',
        '1',
        'There is one entry in the work table after filtering by name "Interlude"',
    );
};

1;
