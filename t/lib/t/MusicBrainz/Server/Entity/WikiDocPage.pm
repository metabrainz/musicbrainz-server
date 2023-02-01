package t::MusicBrainz::Server::Entity::WikiDocPage;
use strict;
use warnings;

use Test::Routine;
use Test::Moose;
use Test::More;

use MusicBrainz::Server::Entity::WikiDocPage;

=head1 DESCRIPTION

This test checks whether WikiDoc page data is stored correctly.

=cut

test 'New WikiDocPage stores the right data' => sub {
    my $page = MusicBrainz::Server::Entity::WikiDocPage->new(
        title => 'About MusicBrainz',
        version => 14508,
        content => '<p>Hello</p>',
    );

    is(
        $page->title,
        'About MusicBrainz',
        'The expected page title is stored',
    );
    is($page->version, 14508, 'The expected page version is stored');
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
