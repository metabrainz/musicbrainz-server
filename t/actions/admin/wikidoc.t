use strict;
use warnings;
use Test::More;

my $index_filename;

BEGIN {
    use File::Temp;
    $index_filename = File::Temp::tmpnam();
    no warnings 'redefine';
    use DBDefs;
    *DBDefs::WIKITRANS_INDEX_FILE = sub { $index_filename };
}

END {
    unlink $index_filename;
}

use MusicBrainz::Server::Test qw( xml_ok );

use Test::WWW::Mechanize::Catalyst;
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

$mech->get('/login');
$mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

open FILE, ">$index_filename";
close FILE;

$mech->get_ok('/admin/wikidoc');
xml_ok($mech->content);
$mech->content_contains('New wiki page');

$mech->get_ok('/admin/wikidoc/create');
xml_ok($mech->content);
$mech->submit_form_ok( { with_fields => {
    'wikidoc.page' => 'WikiPage',
    'wikidoc.version' => '123',
} } );
$mech->content_contains('WikiPage');
$mech->content_contains('123');

$mech->get_ok('/admin/wikidoc/edit?page=WikiPage');
xml_ok($mech->content);
$mech->submit_form_ok( { with_fields => {
    'wikidoc.version' => '124',
} } );
$mech->content_contains('124');

$mech->get_ok('/admin/wikidoc/delete?page=WikiPage');
xml_ok($mech->content);
$mech->submit_form_ok( { form_number => 1 } );
$mech->content_lacks('WikiPage');

done_testing;
