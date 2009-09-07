#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 4;
use_ok 'MusicBrainz::Server::Data::WikiDoc';

use MusicBrainz::Server::Test;
my $c = MusicBrainz::Server::Test->create_test_context();

my $wd = $c->model('WikiDoc');

my $page = $wd->_create_page('Artist_Name', 123, '
<h3><span class="editsection">[<a href="http://wiki.musicbrainz.org/?title=Artist_Name&amp;action=edit&amp;section=6" title="Edit section: Section">edit</a>]</span> Section</h3>
<p>Foo</p>
');

is($page->title, 'Artist Name');
is($page->version, 123);
like($page->content, qr{<h3>Section</h3>});
