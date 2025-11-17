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
            <event-list count="4">
                <event id="3495abf6-4692-45cd-af62-7d964558676a" type="Festival" type-id="b6ded574-b592-3f0e-b56e-5b5f06aa0678">
                    <name>Wacken Open Air 2024, Day 2</name>
                    <life-span>
                        <begin>2024-07-29</begin>
                        <end>2024-07-29</end>
                    </life-span>
                </event>
                <event id="f0ecc038-d229-4b3e-aa98-d5f4de693272" type="Festival" type-id="b6ded574-b592-3f0e-b56e-5b5f06aa0678">
                    <name>Wacken Open Air 2024, Day 2: Welcome to the Jungle</name>
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
                <event id="eddb272f-1f10-4ece-875d-52cd0d3a2bb1" type="Festival" type-id="b6ded574-b592-3f0e-b56e-5b5f06aa0678">
                    <name>Wacken Open Air 2024, Day 3: LGH Clubstage</name>
                    <life-span>
                        <begin>2024-07-30</begin>
                        <end>2024-07-30</end>
                    </life-span>
                </event>
            </event-list>
        </metadata>
        XML

    # We test browsing by three events (A, B, C) which contain a cycle in
    # l_event_event of the form A -> B -> C -> A.

    my $event_cycle_a = <<~'XML';
        <event id="0fcf8392-c3fd-485e-8919-bd4bf9872ff9" type="Concert" type-id="ef55e8d7-3d00-394a-8012-f5506a29ff0b">
            <name>cycle A</name>
            <relation-list target-type="event">
                <relation type="parts" type-id="65742183-b25c-469e-b094-ff6739e6699c">
                    <target>c188cfc1-725d-496b-b7f1-b0258573508b</target>
                    <direction>forward</direction>
                    <event id="c188cfc1-725d-496b-b7f1-b0258573508b" type="Concert" type-id="ef55e8d7-3d00-394a-8012-f5506a29ff0b">
                        <name>cycle B</name>
                    </event>
                </relation>
                <relation type="parts" type-id="65742183-b25c-469e-b094-ff6739e6699c">
                    <target>8b918af8-c275-42e3-858b-2098ea307208</target>
                    <direction>backward</direction>
                    <event id="8b918af8-c275-42e3-858b-2098ea307208" type="Concert" type-id="ef55e8d7-3d00-394a-8012-f5506a29ff0b">
                        <name>cycle C</name>
                    </event>
                </relation>
            </relation-list>
        </event>
        XML

    my $event_cycle_b = <<~'XML';
        <event id="c188cfc1-725d-496b-b7f1-b0258573508b" type="Concert" type-id="ef55e8d7-3d00-394a-8012-f5506a29ff0b">
            <name>cycle B</name>
            <relation-list target-type="event">
                <relation type="parts" type-id="65742183-b25c-469e-b094-ff6739e6699c">
                    <target>0fcf8392-c3fd-485e-8919-bd4bf9872ff9</target>
                    <direction>backward</direction>
                    <event id="0fcf8392-c3fd-485e-8919-bd4bf9872ff9" type="Concert" type-id="ef55e8d7-3d00-394a-8012-f5506a29ff0b">
                        <name>cycle A</name>
                    </event>
                </relation>
                <relation type="parts" type-id="65742183-b25c-469e-b094-ff6739e6699c">
                    <target>8b918af8-c275-42e3-858b-2098ea307208</target>
                    <direction>forward</direction>
                    <event id="8b918af8-c275-42e3-858b-2098ea307208" type="Concert" type-id="ef55e8d7-3d00-394a-8012-f5506a29ff0b">
                        <name>cycle C</name>
                    </event>
                </relation>
            </relation-list>
        </event>
        XML

    my $event_cycle_c = <<~'XML';
        <event id="8b918af8-c275-42e3-858b-2098ea307208" type="Concert" type-id="ef55e8d7-3d00-394a-8012-f5506a29ff0b">
            <name>cycle C</name>
            <relation-list target-type="event">
                <relation type="parts" type-id="65742183-b25c-469e-b094-ff6739e6699c">
                    <target>c188cfc1-725d-496b-b7f1-b0258573508b</target>
                    <direction>backward</direction>
                    <event id="c188cfc1-725d-496b-b7f1-b0258573508b" type="Concert" type-id="ef55e8d7-3d00-394a-8012-f5506a29ff0b">
                        <name>cycle B</name>
                    </event>
                </relation>
                <relation type="parts" type-id="65742183-b25c-469e-b094-ff6739e6699c">
                    <target>0fcf8392-c3fd-485e-8919-bd4bf9872ff9</target>
                    <direction>forward</direction>
                    <event id="0fcf8392-c3fd-485e-8919-bd4bf9872ff9" type="Concert" type-id="ef55e8d7-3d00-394a-8012-f5506a29ff0b">
                        <name>cycle A</name>
                    </event>
                </relation>
            </relation-list>
        </event>
        XML

    ws2_test_xml 'browse events via event (cycle A)',
        '/event?event=0fcf8392-c3fd-485e-8919-bd4bf9872ff9&inc=event-rels' => <<~"XML";
        <?xml version="1.0" encoding="UTF-8"?>
        <metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
            <event-list count="2">
                $event_cycle_b
                $event_cycle_c
            </event-list>
        </metadata>
        XML

    ws2_test_xml 'browse events via event (cycle B)',
        '/event?event=c188cfc1-725d-496b-b7f1-b0258573508b&inc=event-rels' => <<~"XML";
        <?xml version="1.0" encoding="UTF-8"?>
        <metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
            <event-list count="2">
                $event_cycle_a
                $event_cycle_c
            </event-list>
        </metadata>
        XML

    ws2_test_xml 'browse events via event (cycle C)',
        '/event?event=8b918af8-c275-42e3-858b-2098ea307208&inc=event-rels' => <<~"XML";
        <?xml version="1.0" encoding="UTF-8"?>
        <metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
            <event-list count="2">
                $event_cycle_a
                $event_cycle_b
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
