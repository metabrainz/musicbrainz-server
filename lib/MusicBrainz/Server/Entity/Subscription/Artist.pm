package MusicBrainz::Server::Entity::Subscription::Artist;
use Moose;
use namespace::autoclean;

use MusicBrainz::Server::Entity::Types;

with 'MusicBrainz::Server::Entity::Subscription::Active';

has 'artist_id' => (
    isa => 'Int',
    is => 'ro',
);

has 'artist' => (
    isa => 'Artist',
    is => 'rw',
);

sub target_id { shift->artist_id }
sub type { 'artist' }

__PACKAGE__->meta->make_immutable;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
