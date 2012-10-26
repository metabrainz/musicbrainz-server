package t::MusicBrainz::Server::Data::WikiDoc;
use Test::Routine;
use Test::More;

use FindBin qw($Bin);
use LWP;
use LWP::UserAgent::Mockable;
use MusicBrainz::Server::Test;
use Test::More;

use MusicBrainz::Server::Data::WikiDoc;

with 't::Context';

test all => sub {

LWP::UserAgent::Mockable->reset( playback => $Bin.'/lwp-sessions/data_wikidoc.xmlwebservice-redirect.lwp-mock' );
LWP::UserAgent::Mockable->set_playback_validation_callback(\&basic_validation);

my $test = shift;
my $wd = $test->c->model('WikiDoc');

my $page = $wd->_create_page('Artist_Name', 123, '
<h3><span class="editsection">[<a href="http://wiki.musicbrainz.org/?title=Artist_Name&amp;action=edit&amp;section=6" title="Edit section: Section">edit</a>]</span> Section</h3>
<p>Foo</p>
');

is($page->title, 'Artist Name');
is($page->version, 123);
like($page->content, qr{<h3> Section</h3>});

$wd = $test->c->model('WikiDoc');
$page = $wd->get_page('XML_Webservice');
is($page->canonical, 'XML_Web_Service/Version_2', 'Resolved canonical wiki id');

LWP::UserAgent::Mockable->finished;

};

sub basic_validation {
    my ($actual, $expected) = @_;
    is($actual->uri, $expected->uri, 'called ' . $expected->uri);
    is($actual->method, $expected->method, 'method is ' . $expected->method);
}

1;
