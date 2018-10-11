package MusicBrainz::Server::Entity::Role::LastUpdate;

use Moose::Role;
use MusicBrainz::Server::Types qw( PgDateStr );
use namespace::autoclean;
use DateTime::Format::Pg;

has 'last_updated' => (
    is => 'rw',
    isa => PgDateStr,
    coerce => 1,
);

around TO_JSON => sub {
    my ($orig, $self) = @_;

    my $json = $self->$orig;

    my $last_updated = $self->last_updated;
    if (defined $last_updated) {
        $last_updated = DateTime::Format::Pg->parse_datetime($self->last_updated);
        $last_updated->set_time_zone('UTC');
        $json->{last_updated} = $last_updated->iso8601 . 'Z';
    } else {
        $json->{last_updated} = undef;
    }

    return $json;
};

no Moose::Role;
1;

=head1 COPYRIGHT

Copyright (C) 2009 Lukas Lalinsky

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

