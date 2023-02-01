package t::MusicBrainz::Server::Controller::Relationship::LinkType::Index;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok test_xpath_html );

around run_test => sub {
    my ($orig, $test, @args) = @_;
    $test->c->sql->do(<<~'SQL');
        INSERT INTO editor (id, name, password, email, privs, ha1, email_confirm_date)
            VALUES (1, 'editor1', '{CLEARTEXT}pass', 'editor1@example.com', 255, '16a4862191803cb596ee4b16802bb7ee', now())
        SQL

    $test->mech->get('/login');
    $test->mech->submit_form( with_fields => { username => 'editor1', password => 'pass' } );

    $test->$orig(@args);
};

with 't::Mechanize', 't::Context';

test 'Viewing /relationship/artist-artist as admin' => sub {
    my $test = shift;
    my $mech = $test->mech;

    $mech->get_ok('/relationships/artist-artist');
    html_ok($mech->content);
    my $tx = test_xpath_html($mech->content);

    $tx->ok('//a[contains(@href,"/relationship/5be4c609-9afa-4ea0-910b-12ffb71e3821/edit")]',
            'has a link to edit the relationship type');
    $tx->ok('//a[contains(@href,"/relationship/5be4c609-9afa-4ea0-910b-12ffb71e3821/delete")]',
            'has a link to delete the relationship type');
    $tx->ok('//a[contains(@href,"/relationships/artist-artist/create")]',
            'has a link to create new relationship types');
};

test 'Viewing /relationships shows a full tree' => sub {
    my $test = shift;
    my $mech = $test->mech;

    $mech->get_ok('/relationships');
    html_ok($mech->content);
    my $tx = test_xpath_html($mech->content);

    $tx->ok('//a[contains(@href,"/relationships/artist-artist")]',
            'has a link to artist-artist relationships');
    $tx->ok('//a[contains(@href,"/relationships/work-work")]',
            'has a link to work-work relationships');
};

test 'Cannot view impossible relationships' => sub {
    my $test = shift;
    my $mech = $test->mech;

    $mech->get('/relationships/fake-fake');
    is($mech->status, 400);
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
