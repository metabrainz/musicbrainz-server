package MusicBrainz::Server::Entity::Subscription::Series;
use Moose;
use namespace::autoclean;

use MusicBrainz::Server::Entity::Types;

with 'MusicBrainz::Server::Entity::Subscription::Active';

has 'series_id' => (
    isa => 'Int',
    is => 'ro',
);

has 'series' => (
    isa => 'Series',
    is => 'rw',
);

sub target_id { shift->series_id }
sub type { 'series' }

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
