package t::MusicBrainz::Server::WebService::Serializer::JSON::2::Utils;
use strict;
use warnings;

use Test::Routine;
use Test::Fatal;
use Test::More;

use MusicBrainz::Server::Entity::Artist;
use MusicBrainz::Server::WebService::Serializer::JSON::2::Utils qw(
    serializer
);

=head1 DESCRIPTION

This test checks the JSON ws/2 web service picks the right serializer for
the requested entity, and fails correctly if a wrong type is requested.

=cut

test 'Correctly identifies serializers' => sub {
    my $artist = MusicBrainz::Server::Entity::Artist->new();
    my $serializer = serializer($artist);
    isa_ok($serializer,
        'MusicBrainz::Server::WebService::Serializer::JSON::2::Artist');
};

test 'Throws exception if asked to serialize an unknown entity' => sub {
    my $wazoodle = bless { }, 'Wazoodle';
    like(
        exception { serializer($wazoodle) },
        qr/^No serializer found for Wazoodle/,
        'The expected error message is returned',
    );
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
