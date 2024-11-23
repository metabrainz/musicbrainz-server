package t::MusicBrainz::Server::Controller::Search::Direct;
use strict;
use warnings;

use Test::Routine;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c);
MusicBrainz::Server::Test->prepare_test_database($c, <<~'SQL');
    INSERT INTO link (id, link_type, attribute_count) VALUES (1000, 167, 0);
    INSERT INTO l_artist_work (id, entity0, link, entity1)
        VALUES (1000, 6, 1000, 1);
    SQL

$mech->get_ok('/search?query=Kate&type=artist&direct=on', 'perform artist search');
html_ok($mech->content);
$mech->content_contains('3 results', 'has result count');
$mech->content_contains('Kate Bush', 'has correct search result');
$mech->content_contains('Bush, Kate', 'has artist sortname');
$mech->content_contains('/artist/4b585938-f271-45e2-b19a-91c634b5e396', 'has link to artist');

$mech->get_ok('/search?query=Dancing+Queen&type=work&direct=on', 'perform works search');
html_ok($mech->content);
$mech->content_contains('1 result', 'has result count');
$mech->content_contains('Dancing Queen', 'has correct search result');
$mech->content_contains('/work/745c079d-374e-4436-9448-da92dedef3ce', 'has link to work');
$mech->content_contains('/artist/a45c079d-374e-4436-9448-da92dedef3cf', 'has link to artist');
$mech->content_contains('ABBA', 'has artist');

$mech->get_ok('/search?query=Sunset&type=recording&direct=on', 'perform recording search');
html_ok($mech->content);
$mech->content_contains('1 result', 'has result count');
$mech->content_contains('Sunset', 'has correct search result');
$mech->content_contains('/recording/33137503-0ebf-4b6b-a7ce-cc71df5865df', 'has link to recording');
$mech->content_contains('/artist/4b585938-f271-45e2-b19a-91c634b5e396', 'has link to artist');

$mech->get_ok('/search?query=Aerial&type=release&direct=on', 'perform release search');
html_ok($mech->content);
$mech->content_contains('2 results', 'has result count');
$mech->content_contains('Aerial', 'has correct search result');
$mech->content_contains('/release/f205627f-b70a-409d-adbe-66289b614e80', 'has link to release');
$mech->content_contains('/release/9b3d9383-3d2a-417f-bfbb-56f7c15f075b', 'has link to release');
$mech->content_contains('/artist/4b585938-f271-45e2-b19a-91c634b5e396', 'has link to artist');

$mech->get_ok('/search?query=Arrival&type=release_group&direct=on', 'perform release group search');
html_ok($mech->content);
$mech->content_contains('1 result', 'has result count');
$mech->content_contains('Arrival', 'has correct search result');
$mech->content_contains('/release-group/234c079d-374e-4436-9448-da92dedef3ce', 'has link to release group');
$mech->content_contains('/artist/a45c079d-374e-4436-9448-da92dedef3cf', 'has link to artist');
$mech->content_contains('ABBA', 'has artist');

$mech->get_ok('/search?query=united&type=area&method=direct', 'perform area search');
html_ok($mech->content);
$mech->content_contains('2 results', 'has result count');
$mech->content_contains('United Kingdom', 'has correct search result');
$mech->content_contains('/area/489ce91b-6658-3307-9877-795b68554c98', 'has link to area 1');
$mech->content_contains('/area/8a754a16-0027-3a29-b6d7-2b40ea0481ed', 'has link to area 2');
$mech->content_contains('Country', 'has area type');
$mech->content_contains('GB', 'has ISO-3166-1 area code');

$mech->get_ok('/search?query=joe_bloggs&type=editor&method=direct', 'perform editor search');
html_ok($mech->content);
$mech->content_lacks('qoe_bloggs');
$mech->get_ok('/search?query=new_editor&type=editor&method=direct', 'perform editor search');
$mech->content_contains('/user/new_editor');
$mech->text_contains('new_editor');

$mech->get_ok('/search?query=musical&type=tag&direct=on', 'perform tag search');
html_ok($mech->content);
$mech->content_contains('1 result', 'has result count');
$mech->content_contains('musical', 'has correct search result');
$mech->content_contains('/tag/musical', 'has link to the tag');

};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
