package MusicBrainz::Server::Entity::Area;

use Moose;
use MusicBrainz::Server::Translation::Countries qw ( l );
use MusicBrainz::Server::Entity::PartialDate;
use MusicBrainz::Server::Entity::Types;
use List::Util qw( first );

extends 'MusicBrainz::Server::Entity::CoreEntity';
with 'MusicBrainz::Server::Entity::Role::Linkable';
with 'MusicBrainz::Server::Entity::Role::Annotation';
with 'MusicBrainz::Server::Entity::Role::LastUpdate';
with 'MusicBrainz::Server::Entity::Role::Age';

sub l_name {
    my $self = shift;
    return l($self->name);
}

has 'sort_name' => (
    is => 'rw',
    isa => 'Str'
);

has 'type_id' => (
    is => 'rw',
    isa => 'Maybe[Int]'
);

has 'type' => (
    is => 'rw',
    isa => 'AreaType',
);

sub type_name
{
    my ($self) = @_;
    return $self->type ? $self->type->name : undef;
}

sub l_type_name
{
    my ($self) = @_;
    return $self->type ? $self->type->l_name : undef;
}

has 'parent_country' => (
    is => 'rw',
    isa => 'Maybe[Area]',
);

has 'iso_3166_1' => (
    traits => [ 'Array' ],
    is => 'ro',
    isa => 'ArrayRef[Str]',
    default => sub { [] },
    handles => {
        add_iso_3166_1 => 'push',
        iso_3166_1_codes => 'elements',
    }
);

has 'iso_3166_2' => (
    traits => [ 'Array' ],
    is => 'ro',
    isa => 'ArrayRef[Str]',
    default => sub { [] },
    handles => {
        add_iso_3166_2 => 'push',
        iso_3166_2_codes => 'elements',
    }
);

has 'iso_3166_3' => (
    traits => [ 'Array' ],
    is => 'ro',
    isa => 'ArrayRef[Str]',
    default => sub { [] },
    handles => {
        add_iso_3166_3 => 'push',
        iso_3166_3_codes => 'elements',
    }
);

sub primary_code
{
    my ($self) = @_;
    if (scalar $self->iso_3166_1_codes == 1) {
        return first { defined($_) } $self->iso_3166_1_codes;
    }
    elsif (scalar $self->iso_3166_2_codes == 1) {
        return first { defined($_) } $self->iso_3166_2_codes;
    }
    elsif (scalar $self->iso_3166_3_codes == 1) {
        return first { defined($_) } $self->iso_3166_3_codes;
    }
    else {
        warn "Couldn't determine primary code for area " . $self->gid . ". Perhaps codes aren't loaded?";
        return undef;
    }
}

=head2 country_code

This function returns a country (ISO-3166-1) code only. For now, it will only return intrinsic ones;
in the future it may make sense to use the first two characters of an iso-3166-2 code as well.

=cut

sub country_code
{
    my ($self) = @_;
    if (scalar $self->iso_3166_1_codes) {
        return first { defined($_) } $self->iso_3166_1_codes;
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2013 MetaBrainz Foundation

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
