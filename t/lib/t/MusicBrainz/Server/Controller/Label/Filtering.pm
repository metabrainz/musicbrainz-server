package t::MusicBrainz::Server::Controller::Label::Filtering;
use utf8;
use strict;
use warnings;

use Test::Routine;
use MusicBrainz::Server::Test qw( test_xpath_html );

with 't::Mechanize', 't::Context';

=head1 DESCRIPTION

This test checks whether filtering works for release lists
in label pages.

=cut

test 'Release page filtering' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+filtering');

    $mech->get_ok(
        '/label/5a584032-dcef-41bb-9f8b-19540116fb1c',
        'Fetched label page',
    );

    my $tx = test_xpath_html($mech->content);
    $tx->is(
        'count(//table[@class="tbl"]/tbody/tr)',
        '3',
        'There are three entries in the unfiltered release table',
    );

    $mech->get_ok(
        '/label/5a584032-dcef-41bb-9f8b-19540116fb1c?filter.name=Symphony',
        'Fetched label releases page with name filter "Symphony"',
    );

    $tx = test_xpath_html($mech->content);
    $tx->is(
        'count(//table[@class="tbl"]/tbody/tr)',
        '1',
        'There is one entry in the release table after filtering by name',
    );
    $tx->is(
        '//table[@class="tbl"]/tbody/tr[1]/td[1]',
        'Piano Concerto / Symphony no. 2',
        'The entry is named "Piano Concerto / Symphony no. 2"',
    );

    $mech->get_ok(
        '/label/5a584032-dcef-41bb-9f8b-19540116fb1c?filter.artist_credit_id=3400',
        'Fetched label releases page with artist credit filter',
    );

    $tx = test_xpath_html($mech->content);
    $tx->is(
        'count(//table[@class="tbl"]/tbody/tr)',
        '2',
        'There are two entries in the release table after filtering by credit',
    );
    $tx->is(
        '//table[@class="tbl"]/tbody/tr[1]/td[1]',
        'Symphonies / Concertos / Choral and Vocal Works',
        'The first entry is named "Symphonies / Concertos / Choral and Vocal Works"',
    );

    $mech->get_ok(
        '/label/5a584032-dcef-41bb-9f8b-19540116fb1c?filter.status_id=1',
        'Fetched label releases page with status filter "Official"',
    );

    $tx = test_xpath_html($mech->content);
    $tx->is(
        'count(//table[@class="tbl"]/tbody/tr)',
        '2',
        'There are two entries in the release table after filtering by "Official" status',
    );
    $tx->is(
        '//table[@class="tbl"]/tbody/tr[1]/td[1]',
        'Symphonies / Concertos / Choral and Vocal Works',
        'The first entry is named "Symphonies / Concertos / Choral and Vocal Works"',
    );

    $mech->get_ok(
        '/label/5a584032-dcef-41bb-9f8b-19540116fb1c?filter.status_id=-1',
        'Fetched label releases page with status filter "[none]"',
    );

    $tx = test_xpath_html($mech->content);
    $tx->is(
        'count(//table[@class="tbl"]/tbody/tr)',
        '1',
        'There is one entry in the release table after filtering by no status',
    );
    $tx->is(
        '//table[@class="tbl"]/tbody/tr[1]/td[1]',
        'String Quartet',
        'The entry is named "String Quartet"',
    );

    $mech->get_ok(
        '/label/5a584032-dcef-41bb-9f8b-19540116fb1c?filter.date=2010',
        'Fetched label releases page with date filter',
    );

    $tx = test_xpath_html($mech->content);
    $tx->is(
        'count(//table[@class="tbl"]/tbody/tr)',
        '2',
        'There are two entries in the release table after filtering by date',
    );
    $tx->is(
        '//table[@class="tbl"]/tbody/tr[1]/td[1]',
        'Piano Concerto / Symphony no. 2',
        'The first entry is named "Piano Concerto / Symphony no. 2"',
    );

    $mech->get_ok(
        '/label/5a584032-dcef-41bb-9f8b-19540116fb1c?filter.label_id=3402',
        'Fetched label releases page with label filter (for a second label)',
    );

    $tx = test_xpath_html($mech->content);
    $tx->is(
        'count(//table[@class="tbl"]/tbody/tr)',
        '1',
        'There is one entry in the release table after filtering by label',
    );
    $tx->is(
        '//table[@class="tbl"]/tbody/tr[1]/td[1]',
        'Symphonies / Concertos / Choral and Vocal Works',
        'The entry is named "Symphonies / Concertos / Choral and Vocal Works"',
    );

    $mech->get_ok(
        '/label/5a584032-dcef-41bb-9f8b-19540116fb1c?filter.country_id=221',
        'Fetched label releases page with country filter',
    );

    $tx = test_xpath_html($mech->content);
    $tx->is(
        'count(//table[@class="tbl"]/tbody/tr)',
        '1',
        'There is one entry in the release table after filtering by country',
    );
    $tx->is(
        '//table[@class="tbl"]/tbody/tr[1]/td[1]',
        'Piano Concerto / Symphony no. 2',
        'The entry is named "Piano Concerto / Symphony no. 2"',
    );

    $mech->get_ok(
        '/label/5a584032-dcef-41bb-9f8b-19540116fb1c?filter.country_id=-1',
        'Fetched label releases page with country filter "[none]"',
    );

    $tx = test_xpath_html($mech->content);
    $tx->is(
        'count(//table[@class="tbl"]/tbody/tr)',
        '2',
        'There are two entries in the release table after filtering by no country',
    );
    $tx->is(
        '//table[@class="tbl"]/tbody/tr[1]/td[1]',
        'Symphonies / Concertos / Choral and Vocal Works',
        'The entry is named "Symphonies / Concertos / Choral and Vocal Works"',
    );

    $mech->get_ok(
        '/label/5a584032-dcef-41bb-9f8b-19540116fb1c?filter.country_id=-1&filter.date=2010',
        'Fetched label releases page with both date filter and country filter "[none]"',
    );

    $tx = test_xpath_html($mech->content);
    $tx->is(
        'count(//table[@class="tbl"]/tbody/tr)',
        '1',
        'There is one entry in the release table after filtering by no country + date 2010',
    );
    $tx->is(
        '//table[@class="tbl"]/tbody/tr[1]/td[1]',
        'String Quartet',
        'The entry is named "String Quartet"',
    );
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2025 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut