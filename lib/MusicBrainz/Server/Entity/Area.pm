package MusicBrainz::Server::Entity::Area;

use Moose;
use MusicBrainz::Server::Constants qw( $AREA_TYPE_COUNTRY );
use MusicBrainz::Server::Translation::Countries qw( l );
use MusicBrainz::Server::Entity::PartialDate;
use MusicBrainz::Server::Entity::Types;
use List::Util qw( first );
use List::UtilsBy qw( nsort_by );

extends 'MusicBrainz::Server::Entity::CoreEntity';
with 'MusicBrainz::Server::Entity::Role::Taggable';
with 'MusicBrainz::Server::Entity::Role::Linkable';
with 'MusicBrainz::Server::Entity::Role::Annotation';
with 'MusicBrainz::Server::Entity::Role::LastUpdate';
with 'MusicBrainz::Server::Entity::Role::Age';
with 'MusicBrainz::Server::Entity::Role::Comment';
with 'MusicBrainz::Server::Entity::Role::Type' => { model => 'AreaType' };

sub l_name {
    my $self = shift;
    my $type = defined $self->type ? $self->type->id : $self->type_id;
    if (defined $type && $type == $AREA_TYPE_COUNTRY) {
        return l($self->name);
    } else {
        return $self->name;
    }
}

has 'parent_country' => (
    is => 'rw',
    isa => 'Maybe[Area]',
);

has 'parent_country_depth' => (
    is => 'rw',
    isa => 'Maybe[Int]',
);

has 'parent_subdivision' => (
    is => 'rw',
    isa => 'Maybe[Area]',
);

has 'parent_subdivision_depth' => (
    is => 'rw',
    isa => 'Maybe[Int]',
);

has 'parent_city' => (
    is => 'rw',
    isa => 'Maybe[Area]',
);

has 'parent_city_depth' => (
    is => 'rw',
    isa => 'Maybe[Int]',
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

around TO_JSON => sub {
    my ($orig, $self) = @_;

    my $containment = [
        map { $self->$_->TO_JSON }
        nsort_by { $self->${ \"${_}_depth" } }
        grep { $self->$_ }
        qw( parent_city parent_subdivision parent_country )
    ];

    return {
        %{ $self->$orig },
        code => $self->primary_code,
        containment => $containment,
        iso_3166_1_codes => [$self->iso_3166_1_codes],
    };
};

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
