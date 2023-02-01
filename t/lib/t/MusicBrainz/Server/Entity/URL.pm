package t::MusicBrainz::Server::Entity::URL;
use utf8;
use strict;
use warnings;

use Test::Routine;
use Test::Moose;
use Test::More;

use MusicBrainz::Server::Entity::URL;

=head1 DESCRIPTION

This test checks whether URL pretty names are generated correctly
when they have Unicode characters.

=cut

test 'Pretty name is decoded if the URL is UTF-8' => sub {
    my $url = MusicBrainz::Server::Entity::URL->new(
        url => 'http://www.discogs.com/artist/%D0%97%D0%B5%D0%BC%D1%84%D0%B8%D1%80%D0%B0',
    );

    is (
        $url->pretty_name => 'http://www.discogs.com/artist/Земфира',
        'The expected URL name is decoded for display for UTF-8 URLs',
    );
};

test 'Pretty name is not decoded if the URL is not UTF-8' => sub {
    my $url = MusicBrainz::Server::Entity::URL->new(
        url => 'http://www.invalid.fail/%FC'
    );

    is (
        $url->pretty_name => 'http://www.invalid.fail/%FC',
        'No pretty name is decoded for display for non-UTF-8 URLs',
    );
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
