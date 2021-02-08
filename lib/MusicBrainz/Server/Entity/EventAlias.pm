package MusicBrainz::Server::Entity::EventAlias;

use Moose;
use MusicBrainz::Server::Entity::Types;

extends 'MusicBrainz::Server::Entity::Alias';

sub entity_type { 'event_alias' }

has event_id => (
    is => 'rw',
    isa => 'Int'
);

has event => (
    is => 'rw',
    isa => 'Event'
);

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
