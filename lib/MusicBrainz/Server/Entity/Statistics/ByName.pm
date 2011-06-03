package MusicBrainz::Server::Entity::Statistics::ByName;
use Moose;

use MusicBrainz::Server::Types;
use MusicBrainz::Server::Data::Statistics;
use MooseX::Types::Moose qw( Str Int );
use MooseX::Types::Structured qw( Map );

has data => (
    is => 'rw',
    isa => Map[ Str, Int ], # Map date to value
    traits => [ 'Hash' ],
    default => sub { {} },
    handles => {
        statistic_for => 'get'
    }
);

has name => (
   is => 'rw',
   isa => 'Str'
);

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2011 MetaBrainz Foundation Inc.

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut
