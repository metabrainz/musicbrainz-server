package MusicBrainz::Server::Entity::ISRC;

use Moose;
use Readonly;
use MusicBrainz::Server::Entity::Types;

extends 'MusicBrainz::Server::Entity';
with 'MusicBrainz::Server::Entity::Role::Editable';

sub entity_type { 'isrc' }

has 'isrc' => (
    is => 'rw',
    isa => 'Str'
);

has 'recording_id' => (
    is => 'rw',
    isa => 'Int'
);

has 'recording' => (
    is => 'rw',
    isa => 'Recording'
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

sub name { shift->isrc }

around TO_JSON => sub {
    my ($orig, $self) = @_;

    if ($self->recording) {
        $self->link_entity('recording', $self->recording_id, $self->recording);
    }

    my $json = $self->$orig;
    $json->{isrc} = $self->isrc;
    $json->{recording_id} = $self->recording_id;
    return $json;
};

__PACKAGE__->meta->make_immutable;
no Moose;
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
