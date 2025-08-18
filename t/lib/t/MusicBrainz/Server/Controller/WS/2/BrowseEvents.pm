package t::MusicBrainz::Server::Controller::WS::2::BrowseEvents;

use strict;
use warnings;

use Test::Routine;

use MusicBrainz::Server::Test::WS qw( ws2_test_xml );

with 't::Mechanize', 't::Context';

test all => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+event');

    ws2_test_xml 'browse events via event',
        '/event?event=183ba1ec-a87b-4c0e-85dd-496b7cea4399' => <<~'XML';
        <?xml version="1.0" encoding="UTF-8"?>
        <metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
            <event-list count="2">
                <event id="3495abf6-4692-45cd-af62-7d964558676a" type="Festival" type-id="b6ded574-b592-3f0e-b56e-5b5f06aa0678">
                    <name>Wacken Open Air 2024, Day 2</name>
                    <life-span>
                        <begin>2024-07-29</begin>
                        <end>2024-07-29</end>
                    </life-span>
                </event>
                <event id="6b67008c-55a1-44a4-98be-ecfdebc18987" type="Festival" type-id="b6ded574-b592-3f0e-b56e-5b5f06aa0678">
                    <name>Wacken Open Air 2024, Day 3</name>
                    <life-span>
                        <begin>2024-07-30</begin>
                        <end>2024-07-30</end>
                    </life-span>
                </event>
            </event-list>
        </metadata>
        XML
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2025 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
