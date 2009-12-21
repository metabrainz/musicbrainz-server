use strict;
use warnings;

use Catalyst::Test 'MusicBrainz::Server';
use MusicBrainz::Server::Test qw( xml_ok );
use Test::More;
use Test::WWW::Mechanize::Catalyst;

my ($res, $c) = ctx_request('/');
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

# Deleting artists is now not done through the website at all
my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_ARTIST_DELETE,
        artist_id => 3,
        editor_id => 1
    );

TODO:
{
    local $TODO = 'fetch the edit page';
    $mech->get_ok('/edit/' . $edit->id);
}

done_testing;
