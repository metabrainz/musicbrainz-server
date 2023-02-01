package MusicBrainz::Server::Entity::CollectionSubscription;
use Moose;
use namespace::autoclean;

use MusicBrainz::Server::Entity::Types;

with 'MusicBrainz::Server::Entity::Subscription::Active';

has 'collection_id' => (
    isa => 'Int',
    is => 'ro',
);

has 'collection' => (
    isa => 'Collection',
    is => 'rw',
);

has 'available' => (
    isa => 'Bool',
    is => 'ro'
);

has 'last_seen_name' => (
    isa => 'Str',
    is => 'ro'
);

sub target_id { shift->collection_id }
sub type { 'collection' }

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
