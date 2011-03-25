package t::MusicBrainz::Server::Data::WikiDoc;
use Test::Routine;
use Test::More;

use FindBin qw($Bin);
use LWP;
use LWP::UserAgent::Mockable;
use MusicBrainz::Server::Test;
use Test::More;
use Test::Memory::Cycle;

use MusicBrainz::Server::Data::WikiDoc;

with 't::Context';

test all => sub {

$ENV{ LWP_UA_MOCK } ||= 'playback';
$ENV{ LWP_UA_MOCK_FILE } ||= $Bin.'/data_wikidoc.xmlwebservice-redirect.lwp-mock';

my $test = shift;
my $wd = $test->c->model('WikiDoc');
memory_cycle_ok($wd);

my $page = $wd->_create_page('Artist_Name', 123, '
<h3><span class="editsection">[<a href="http://wiki.musicbrainz.org/?title=Artist_Name&amp;action=edit&amp;section=6" title="Edit section: Section">edit</a>]</span> Section</h3>
<p>Foo</p>
');

is($page->title, 'Artist Name');
is($page->version, 123);
like($page->content, qr{<h3> Section</h3>});
memory_cycle_ok($wd);
memory_cycle_ok($page);

$wd = $test->c->model('WikiDoc');
$page = $wd->get_page('XML_Webservice');
is($page->canonical, 'XML_Web_Service', 'Resolved canonical wiki id');
memory_cycle_ok($wd);
memory_cycle_ok($page);

LWP::UserAgent::Mockable->finished;

};

1;
