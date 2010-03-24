#!/usr/bin/perl
use strict;
use warnings;
use FindBin qw($Bin);
use Test::More;
use_ok 'MusicBrainz::Server::Data::WikiDoc';

BEGIN {
    $ENV{ LWP_UA_MOCK } ||= 'playback';
    $ENV{ LWP_UA_MOCK_FILE } ||= $Bin.'/data_wikidoc.xmlwebservice-redirect.lwp-mock';
}

use LWP;
use LWP::UserAgent::Mockable;

use MusicBrainz::Server::Test;
my $c = MusicBrainz::Server::Test->create_test_context();

my $wd = $c->model('WikiDoc');

my $page = $wd->_create_page('Artist_Name', 123, '
<h3><span class="editsection">[<a href="http://wiki.musicbrainz.org/?title=Artist_Name&amp;action=edit&amp;section=6" title="Edit section: Section">edit</a>]</span> Section</h3>
<p>Foo</p>
');

is($page->title, 'Artist Name');
is($page->version, 123);
like($page->content, qr{<h3> Section</h3>});

$wd = $c->model('WikiDoc');
$page = $wd->get_page('XML_Webservice');
is($page->canonical, 'XML_Web_Service', 'Resolved canonical wiki id');

LWP::UserAgent::Mockable->finished;

done_testing;

1;
