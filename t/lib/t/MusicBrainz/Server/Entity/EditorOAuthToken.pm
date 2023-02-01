package t::MusicBrainz::Server::Entity::EditorOAuthToken;
use strict;
use warnings;

use Test::Routine;
use Test::Moose;
use Test::More;

use MusicBrainz::Server::Entity::EditorOAuthToken;

use DateTime;

=head1 DESCRIPTION

This test checks whether OAuth tokens get correctly marked as expired.

=cut

test 'Token with expire_time in the future is not marked expired' => sub {
    my $token = MusicBrainz::Server::Entity::EditorOAuthToken->new(
        expire_time => DateTime->now->add(hours => 1),
    );
    ok(!$token->is_expired, 'Token is not expired');
};

test 'Token with expire_time in the past is marked expired' => sub {
    my $token = MusicBrainz::Server::Entity::EditorOAuthToken->new(
        expire_time => DateTime->now->add(hours => -1),
    );
    ok($token->is_expired, 'Token is expired');
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
