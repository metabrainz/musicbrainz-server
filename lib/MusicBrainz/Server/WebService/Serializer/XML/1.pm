package MusicBrainz::Server::WebService::Serializer::XML::1;

use Moose;
use MusicBrainz::XML::Generator;

has 'attributes' => (
    is => 'rw',
    isa => 'HashRef[Str]',
    default => sub { { } },
);

has 'children' => (
    is => 'rw',
    isa => 'ArrayRef[Str]',
    default => sub { [ ] },
);

our $gen = MusicBrainz::XML::Generator->new(
    escape => 'always,even-entities'
);

has 'gen' => (
    is => 'rw',
    isa => 'MusicBrainz::XML::Generator',
    default => sub {
        $gen
    },
);

sub add
{
    my $self = shift;

    push @{$self->children}, @_;
}

sub serialize
{
    my ($self, $entity, $inc, $opts) = @_;

    my $element = $self->element;

    return $self->gen->$element($self->attributes, @{$self->children});
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2010 MetaBrainz Foundation

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

