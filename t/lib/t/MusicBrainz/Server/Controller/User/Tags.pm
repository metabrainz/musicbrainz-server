package t::MusicBrainz::Server::Controller::User::Tags;
use strict;
use warnings;

use Test::Routine;
use Test::More;

with 't::Mechanize', 't::Context';

test all => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+editor');
    MusicBrainz::Server::Test->prepare_test_database($c, <<~'SQL');
        INSERT INTO artist (id, gid, name, sort_name)
            VALUES (7, 'b9d99e40-72d7-11de-8a39-0800200c9a66', 'Kate Bush', 'Kate Bush');
        TRUNCATE artist_tag_raw CASCADE;
        INSERT INTO tag (id, name) VALUES (1, 'not a musical');
        INSERT INTO artist_tag_raw (artist, editor, tag, is_upvote)
            VALUES (7, 1, 1, 't');
        SQL

    $mech->get('/user/new_editor/tags');
    $mech->content_contains('not a musical', q(new_editor has used the tag 'not a musical'));

    $mech->get('/user/alice/tags');
    is($mech->status, 403, q(alice's tag list is private));

    $mech->get('/user/alice/tag/not%20a%20musical');
    is($mech->status, 403, q(alice's tag pages are private));

    $mech->get('/login');
    $mech->submit_form(with_fields => { username => 'new_editor', password => 'password' });

    $mech->get('/user/alice/tags');
    is($mech->status, 403, q(alice's tags are still private));

    $mech->get('/logout');
    $mech->get('/login');
    $mech->submit_form(with_fields => { username => 'alice', password => 'secret1' });

    $mech->get('/user/alice/tags');
    is($mech->status, 200, 'alice can view her own tags');
    $mech->content_contains('Alice</bdi></a> has not upvoted any tags', 'alice has not tagged anything');
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2016 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
