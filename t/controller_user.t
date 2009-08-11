#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 19;

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;
my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c, '+editor');
MusicBrainz::Server::Test->prepare_test_server();

use Test::WWW::Mechanize::Catalyst;
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

# Test login
$mech->get_ok('/login');
$mech->submit_form( with_fields => { username => '', password => '' } );
$mech->content_contains('Incorrect username or password');
$mech->submit_form( with_fields => { username => 'new_editor', password => '' } );
$mech->content_contains('Incorrect username or password');
$mech->submit_form( with_fields => { username => '', password => 'password' } );
$mech->content_contains('Incorrect username or password');
$mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );
is($mech->uri->path, '/user/profile/new_editor');

# Test logout
$mech->get('/');
$mech->get_ok('/logout');
is($mech->uri->path, '/', 'Redirected to the previous URL');
$mech->get_ok('/user/profile/new_editor');
$mech->content_contains('Please log in using the form below');
$mech->get('/login');
$mech->get_ok('/logout');
is($mech->uri->path, '/login', 'Redirected to the previous URL');

# XXX change email sending so that it's testable
$mech->get_ok('/lost-username');
$mech->get_ok('/lost-password');
$mech->get_ok('/reset-password');

$mech->get('/login');
$mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );
$mech->get_ok('/account/edit');
$mech->submit_form( with_fields => {
    'profile.website' => 'foo',
    'profile.biography' => 'hello world!',
} );
$mech->content_contains('Invalid URL format');
$mech->submit_form( with_fields => {
    'profile.website' => 'http://example.com/~new_editor/',
    'profile.biography' => 'hello world!',
} );
$mech->content_contains('Your profile has been updated');
$mech->get('/user/profile/new_editor');
$mech->content_contains('http://example.com/~new_editor/');
$mech->content_contains('hello world!');
