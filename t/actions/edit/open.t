use strict;
use warnings;

use Catalyst::Test 'MusicBrainz::Server';
use MusicBrainz::Server::Test qw( accept_edit xml_ok );
use Test::More;
use Test::WWW::Mechanize::Catalyst;

my $c = MusicBrainz::Server::Test->create_test_context;
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

$mech->get('/login');
$mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

{
    package FakeEdit;
    use Moose;
    extends 'MusicBrainz::Server::Edit';
    sub edit_type { 9000 }
    sub edit_name { 'Edit artist' } # Just so it grabs an edit template
    sub initialize {
        my $self = shift;
        $self->data({ fake => 'data' });
    }
}

MusicBrainz::Server::EditRegistry->register_type('FakeEdit');

my $open = $c->model('Edit')->create(
    editor_id => 1,
    edit_type => 9000
);

$mech->get_ok('/edit/open', 'fetch open edits');
xml_ok($mech->content);
$mech->content_contains('/edit/' . $open->id);

accept_edit($c, $open);

$mech->get_ok('/edit/open', 'fetch open edits');
xml_ok($mech->content);
$mech->content_lacks('/edit/' . $open->id);

done_testing;
