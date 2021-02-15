package MusicBrainz::Server::Entity::DurationLookupResult;

use Moose;
use MusicBrainz::Server::Entity::Types;

has 'distance' => (
    is => 'rw',
    isa => 'Int'
);

has 'medium_id' => (
    is => 'rw',
    isa => 'Int'
);

has 'medium' => (
    is => 'rw',
    isa => 'Medium'
);


__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
