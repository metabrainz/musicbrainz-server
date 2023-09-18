package t::MusicBrainz::Server::Controller::ReadOnlyPages;
use strict;
use warnings;

use Test::Routine;
use Test::More;

use DBDefs;
use DBDefs::Default;
use HTTP::Status qw( :constants );
use Hook::LexWrap;

with 't::Context', 't::Mechanize';

for my $path (
    '/verify-email',
    '/reset-password',
    '/account/edit',
    '/account/change-password',
    '/account/preferences',
    '/register',
    '/account/applications/register',
    (
        map {
            ("/account/subscriptions/$_/add",
             "/account/subscriptions/$_/remove")
        } qw( artist collection editor label )
    ),
    '/admin/wikidoc/create',
    '/admin/wikidoc/edit',
    '/admin/wikidoc/delete',
    '/edit/enter_votes',
) {
    test "Cannot browse $path when DB_READ_ONLY is set" => sub {
        my $test = shift;
        my $c = $test->c;
        my $mech = $test->mech;

        MusicBrainz::Server::Test->prepare_test_database($c, '+controller_artist');
        $c->sql->do('UPDATE editor SET privs=255');

        $mech->get_ok('/login');
        $mech->submit_form(
            with_fields => { username => 'new_editor', password => 'password' }
        );

        my $dbdefs = ref(*DBDefs::DB_READ_ONLY) ? 'DBDefs' : 'DBDefs::Default';
        # This is a lexically scoped wrapper so the assignment is needed
        # See https://metacpan.org/pod/Hook::LexWrap#Lexically-scoped-wrappers
        my $wrapped_read_only = wrap "${dbdefs}::DB_READ_ONLY",
            pre => sub { $_[-1] = 1 };

        $mech->get($path);
        is($mech->status, HTTP_BAD_REQUEST);

        $wrapped_read_only->DESTROY;
    };
};

1;
