package t::MusicBrainz::Server::Controller::WS::2::BrowseEvents;

use strict;
use warnings;

use HTTP::Status qw( :constants );
use Test::Routine;

use MusicBrainz::Server::Test::WS qw( ws_test ws2_test_xml );

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

    ws2_test_xml 'browse events via multiple events',
        '/event?event=3495abf6-4692-45cd-af62-7d964558676a' .
            '&event=6b67008c-55a1-44a4-98be-ecfdebc18987&inc=event-rels' => <<~'XML';
        <?xml version="1.0" encoding="UTF-8"?>
        <metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
            <event-list count="3">
                <event id="f0ecc038-d229-4b3e-aa98-d5f4de693272" type="Festival" type-id="b6ded574-b592-3f0e-b56e-5b5f06aa0678">
                    <name>Wacken Open Air 2024, Day 2: Welcome to the Jungle</name>
                    <life-span>
                        <begin>2024-07-29</begin>
                        <end>2024-07-29</end>
                    </life-span>
                    <relation-list target-type="event">
                        <relation type="parts" type-id="65742183-b25c-469e-b094-ff6739e6699c">
                            <target>3495abf6-4692-45cd-af62-7d964558676a</target>
                            <direction>backward</direction>
                            <event id="3495abf6-4692-45cd-af62-7d964558676a" type="Festival" type-id="b6ded574-b592-3f0e-b56e-5b5f06aa0678">
                                <name>Wacken Open Air 2024, Day 2</name>
                                <life-span>
                                    <begin>2024-07-29</begin>
                                    <end>2024-07-29</end>
                                </life-span>
                            </event>
                        </relation>
                    </relation-list>
                </event>
                <event id="eddb272f-1f10-4ece-875d-52cd0d3a2bb1" type="Festival" type-id="b6ded574-b592-3f0e-b56e-5b5f06aa0678">
                    <name>Wacken Open Air 2024, Day 3: LGH Clubstage</name>
                    <life-span>
                        <begin>2024-07-30</begin>
                        <end>2024-07-30</end>
                    </life-span>
                    <relation-list target-type="event">
                        <relation type="parts" type-id="65742183-b25c-469e-b094-ff6739e6699c">
                            <target>6b67008c-55a1-44a4-98be-ecfdebc18987</target>
                            <direction>backward</direction>
                            <event id="6b67008c-55a1-44a4-98be-ecfdebc18987" type="Festival" type-id="b6ded574-b592-3f0e-b56e-5b5f06aa0678">
                                <name>Wacken Open Air 2024, Day 3</name>
                                <life-span>
                                    <begin>2024-07-30</begin>
                                    <end>2024-07-30</end>
                                </life-span>
                            </event>
                        </relation>
                    </relation-list>
                </event>
                <event id="183ba1ec-a87b-4c0e-85dd-496b7cea4399" type="Festival" type-id="b6ded574-b592-3f0e-b56e-5b5f06aa0678">
                    <name>Wacken Open Air 2024</name>
                    <life-span>
                        <begin>2024-07-31</begin>
                        <end>2024-08-03</end>
                    </life-span>
                    <relation-list target-type="event">
                        <relation type="parts" type-id="65742183-b25c-469e-b094-ff6739e6699c">
                            <target>3495abf6-4692-45cd-af62-7d964558676a</target>
                            <direction>forward</direction>
                            <event id="3495abf6-4692-45cd-af62-7d964558676a" type="Festival" type-id="b6ded574-b592-3f0e-b56e-5b5f06aa0678">
                                <name>Wacken Open Air 2024, Day 2</name>
                                <life-span>
                                    <begin>2024-07-29</begin>
                                    <end>2024-07-29</end>
                                </life-span>
                            </event>
                        </relation>
                        <relation type="parts" type-id="65742183-b25c-469e-b094-ff6739e6699c">
                            <target>6b67008c-55a1-44a4-98be-ecfdebc18987</target>
                            <direction>forward</direction>
                            <event id="6b67008c-55a1-44a4-98be-ecfdebc18987" type="Festival" type-id="b6ded574-b592-3f0e-b56e-5b5f06aa0678">
                                <name>Wacken Open Air 2024, Day 3</name>
                                <life-span>
                                    <begin>2024-07-30</begin>
                                    <end>2024-07-30</end>
                                </life-span>
                            </event>
                        </relation>
                    </relation-list>
                </event>
            </event-list>
        </metadata>
        XML

    ws_test 'browse events via multiple events (invalid mbid)',
        '/event?event=3495abf6-4692-45cd-af62-7d964558676a&event=abc' =>
        <<~'XML', {response_code => HTTP_BAD_REQUEST};
        <?xml version="1.0" encoding="UTF-8"?>
        <error>
            <text>Invalid mbid 'abc'.</text>
            <text>For usage, please see: https://musicbrainz.org/development/mmd</text>
        </error>
        XML
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2025 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
