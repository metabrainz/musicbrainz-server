package t::MusicBrainz::Server::Controller::WS::2::GenreList;
use utf8;
use strict;
use warnings;

use Test::Routine;

use MusicBrainz::Server::Test::WS qw( ws2_test_xml );

with 't::Mechanize', 't::Context';

=head1 DESCRIPTION

This test ensures the full genre list at genre/all is working as intended.

=cut

test 'Genre list is returned as expected' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');

    ws2_test_xml 'genre list',
        '/genre/all' =>
        '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
  <genre-list count="10">
    <genre id="aac07ae0-8acf-4249-b5c0-2762b53947a2">
      <name>big beat</name>
    </genre>
    <genre id="1b50083b-1afa-4778-82c8-548b309af783">
      <name>dubstep</name>
    </genre>
    <genre id="89255676-1f14-4dd8-bbad-fca839d6aff4">
      <name>electronic</name>
    </genre>
    <genre id="53a3cea3-17af-4421-a07a-5824b540aeb5">
      <name>electronica</name>
    </genre>
    <genre id="18b010d7-7d85-4445-a4a8-1889a4688308">
      <name>glitch</name>
    </genre>
    <genre id="51cfaac4-6696-480b-8f1b-27cfc789109c">
      <name>grime</name>
      <disambiguation>stuff</disambiguation>
    </genre>
    <genre id="a2782cb6-1cd0-477c-a61d-b3f8b42dd1b3">
      <name>house</name>
    </genre>
    <genre id="eba7715e-ee26-4989-8d49-9db382955419">
      <name>j-pop</name>
    </genre>
    <genre id="b74b3b6c-0700-46b1-aa55-1f2869a3bd1a">
      <name>k-pop</name>
    </genre>
    <genre id="911c7bbb-172d-4df8-9478-dbff4296e791">
      <name>pop</name>
    </genre>
  </genre-list>
</metadata>';
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2019 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
