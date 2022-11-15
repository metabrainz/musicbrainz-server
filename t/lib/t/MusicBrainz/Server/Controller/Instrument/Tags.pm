package t::MusicBrainz::Server::Controller::Instrument::Tags;
use strict;
use warnings;

use Test::Routine;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

=head1 DESCRIPTION

This test checks whether instrument tagging is working correctly. It checks
both up- and downvoting, plus withdrawing/removing tags.

=cut

test 'Instrument tagging (up/downvoting, withdrawing)' => sub {
    my $test = shift;
    my $mech = $test->mech;

    MusicBrainz::Server::Test->prepare_test_database($test->c);

    $test->c->sql->do(<<~'SQL');
        INSERT INTO instrument (id, gid, name)
        VALUES (5, '945c079d-374e-4436-9448-da92dedef3cf', 'Minimal Instrument')
        SQL

    $mech->get_ok(
        '/instrument/945c079d-374e-4436-9448-da92dedef3cf/tags',
        'Fetched the instrument tags page',
    );
    html_ok($mech->content);
    $mech->content_contains(
        'Nobody has tagged this yet',
        'The "not tagged yet" message is present',
    );

    $mech->get_ok('/login');
    $mech->submit_form(with_fields => {username => 'new_editor', password => 'password'});

    $mech->get_ok(
        '/instrument/945c079d-374e-4436-9448-da92dedef3cf/tags/upvote?tags=Jazzy, Bassy',
        'Upvoted tags "jazzy" and "bassy"',
    );
    $mech->get_ok(
        '/instrument/945c079d-374e-4436-9448-da92dedef3cf/tags',
        'Fetched the instrument tags page again',
    );
    html_ok($mech->content);
    $mech->content_contains('jazzy', 'Upvoted tag "jazzy" is present');
    $mech->content_contains('bassy', 'Upvoted tag "bassy" is present');


    $mech->get_ok(
        '/instrument/945c079d-374e-4436-9448-da92dedef3cf/tags/withdraw?tags=Jazzy, Bassy',
        'Withdrew tags "jazzy" and "bassy"',
    );
    $mech->get_ok(
        '/instrument/945c079d-374e-4436-9448-da92dedef3cf/tags',
        'Fetched the instrument tags page again',
    );
    html_ok($mech->content);
    $mech->content_lacks('jazzy', 'Withdrawn tag "jazzy" is missing');
    $mech->content_lacks('bassy', 'Withdrawn tag "bassy" is missing');

    $mech->get_ok(
        '/instrument/945c079d-374e-4436-9448-da92dedef3cf/tags/downvote?tags=Jazzy, Bassy',
        'Downvoted tags "jazzy" and "bassy"',
    );
    $mech->get_ok(
        '/instrument/945c079d-374e-4436-9448-da92dedef3cf/tags',
        'Fetched the instrument tags page again',
    );
    html_ok($mech->content);
    $mech->content_contains('jazzy', 'Downvoted tag "jazzy" is present');
    $mech->content_contains('bassy', 'Downvoted tag "bassy" is present');
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2015 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
