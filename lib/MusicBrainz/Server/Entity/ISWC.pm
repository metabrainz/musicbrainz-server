package MusicBrainz::Server::Entity::ISWC;

use Moose;
use Readonly;
use MusicBrainz::Server::Entity::Types;

extends 'MusicBrainz::Server::Entity';
with 'MusicBrainz::Server::Entity::Role::Editable';

has 'iswc' => (
    is => 'rw',
    isa => 'Str'
);

has 'work_id' => (
    is => 'rw',
    isa => 'Int'
);

has 'work' => (
    is => 'rw',
    isa => 'Work'
);

has 'source_id' => (
    is => 'rw',
    isa => 'Int'
);

Readonly my $SOURCE_MUSICBRAINZ => 0;

Readonly my %SOURCES => (
    $SOURCE_MUSICBRAINZ => 'MusicBrainz',
);

sub source
{
    my ($self) = @_;

    return defined $self->source_id ? $SOURCES{$self->source_id} : undef;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2012 MetaBrainz Foundation

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
