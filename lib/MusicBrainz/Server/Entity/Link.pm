package MusicBrainz::Server::Entity::Link;
use Moose;

use MusicBrainz::Server::Entity::PartialDate;
use MusicBrainz::Server::Entity::Types;
use MusicBrainz::Server::Translation qw( l );

extends 'MusicBrainz::Server::Entity';

has 'type_id' => (
    is => 'rw',
    isa => 'Int',
);

has 'type' => (
    is => 'rw',
    isa => 'LinkType',
);

has 'begin_date' => (
    is => 'rw',
    isa => 'PartialDate',
    lazy => 1,
    default => sub { MusicBrainz::Server::Entity::PartialDate->new() },
);

has 'end_date' => (
    is => 'rw',
    isa => 'PartialDate',
    lazy => 1,
    default => sub { MusicBrainz::Server::Entity::PartialDate->new() },
);

has 'ended' => (
    is => 'rw',
    isa => 'Bool',
);

has 'attributes' => (
    is => 'rw',
    isa => 'ArrayRef[LinkAttributeType]',
    traits => [ 'Array' ],
    default => sub { [] },
    lazy => 1,
    handles => {
        clear_attributes => 'clear',
        all_attributes   => 'elements',
        add_attribute    => 'push'
    }
);

has 'formatted_date' => (
    is => 'ro',
    builder => '_build_formatted_date',
    lazy => 1
);

sub has_attribute
{
    my ($self, $name) = @_;

    $name = lc $name;
    foreach my $attr ($self->all_attributes) {
        if (defined $attr->root && lc $attr->root->name eq $name) {
            return 1;
        }
    }
    return 0;
}

sub get_attribute
{
    my ($self, $name) = @_;

    my @values;
    $name = lc $name;
    foreach my $attr ($self->all_attributes) {
        if (defined $attr->root && lc $attr->root->name eq $name) {
            push @values, lc $attr->name;
        }
    }
    return \@values;
}

sub get_attribute_hash
{
    my ($self) = @_;

    my %hash;
    foreach ($self->all_attributes) {
        if ($_->id != $_->root->id) {
            my $attrs = $hash{ $_->root->name } //= [];
            push @$attrs, $_->id;
        } else {
            $hash{ $_->root->name } = 1;
        }
    }
    return \%hash;
}

sub _build_formatted_date {
    my ($self) = @_;

    my $begin_date = $self->begin_date;
    my $end_date = $self->end_date;
    my $ended = $self->ended;

    if ($begin_date->is_empty && $end_date->is_empty) {
        return $ended ? l(' &#x2013; ????') : '';
    }
    if ($begin_date->format eq $end_date->format) {
        return $begin_date->format;
    }
    if (!$begin_date->is_empty && !$end_date->is_empty) {
        return l('{begindate} &#x2013; {enddate}',
            { begindate => $begin_date->format, enddate => $end_date->format });
    }
    if ($begin_date->is_empty) {
        return l('&#x2013; {enddate}', { enddate => $end_date->format });
    }
    if ($end_date->is_empty) {
        return l('{begindate} &#x2013;' . ($ended ? ' ????' : ''),
            { begindate => $begin_date->format });
    }
    return '';
}

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
