package t::MusicBrainz::Server::Entity::Rating;
use strict;
use warnings;

use Test::Routine;
use Test::Moose;

use MusicBrainz::Server::Entity::Rating;

=head1 DESCRIPTION

This test ensures that Rating has the expected attributes.

=cut

test 'Rating has the expected attributes' => sub {
    my $rating = MusicBrainz::Server::Entity::Rating->new();
    has_attribute_ok($rating, $_) for qw( editor_id editor rating );
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2022 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
