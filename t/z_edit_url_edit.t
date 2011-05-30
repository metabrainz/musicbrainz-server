#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'MusicBrainz::Server::Edit::URL::Edit' };

use MusicBrainz::Server::Constants qw( $EDIT_URL_EDIT );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c, '+url-truncate');
MusicBrainz::Server::Test->prepare_test_database($c, '+url');
MusicBrainz::Server::Test->prepare_raw_test_database($c);

my $url = $c->model('URL')->get_by_id(1);
is_unchanged($url);
is($url->edits_pending, 0);

my $edit = create_edit($url);
isa_ok($edit, 'MusicBrainz::Server::Edit::URL::Edit');

$url = $c->model('URL')->get_by_id(1);
is_unchanged($url);
is($url->edits_pending, 1);

reject_edit($c, $edit);

$url = $c->model('URL')->get_by_id(1);
is_unchanged($url);
is($url->edits_pending, 0);

$url = $c->model('URL')->get_by_id(1);
$edit = create_edit($url);
accept_edit($c, $edit);

$url = $c->model('URL')->get_by_id(1);
is($url->url, 'http://google.com/');
is($url->description, 'Google');
is($url->edits_pending, 0);

done_testing;

sub create_edit {
    my $url = shift;
    return $c->model('Edit')->create(
        edit_type => $EDIT_URL_EDIT,
        editor_id => 1,
        to_edit => $url,
        url => 'http://google.com/',
        description => 'Google'
    );
}

sub is_unchanged {
    my $url = shift;
    subtest 'check url hasnt changed' => sub {
        plan tests => 2;
        is($url->url, 'http://musicbrainz.org/');
        is($url->description, 'MusicBrainz');
    }
}
