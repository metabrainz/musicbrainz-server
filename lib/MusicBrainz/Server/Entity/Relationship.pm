package MusicBrainz::Server::Entity::Relationship;

use Moose;
use Readonly;
use MusicBrainz::Server::Entity::Types;
use MusicBrainz::Server::Validation;

Readonly our $DIRECTION_FORWARD  => 1;
Readonly our $DIRECTION_BACKWARD => 2;

extends 'MusicBrainz::Server::Entity';
with  'MusicBrainz::Server::Entity::Role::Editable';

has 'link_id' => (
    is => 'rw',
    isa => 'Int',
);

has 'link' => (
    is => 'rw',
    isa => 'Link',
);

has 'direction' => (
    is => 'rw',
    isa => 'Int',
    default => $DIRECTION_FORWARD
);

has 'entity0_id' => (
    is => 'rw',
    isa => 'Int',
);

has 'entity0' => (
    is => 'rw',
    isa => 'Linkable',
);

has 'entity1_id' => (
    is => 'rw',
    isa => 'Int',
);

has 'entity1' => (
    is => 'rw',
    isa => 'Linkable',
);

has 'phrase' => (
    is => 'ro',
    builder => '_build_phrase',
    lazy => 1
);

has 'verbose_phrase' => (
    is => 'ro',
    builder => '_build_verbose_phrase',
    lazy => 1
);

sub source
{
    my ($self) = @_;
    return ($self->direction == $DIRECTION_FORWARD)
        ? $self->entity0 : $self->entity1;
}

sub source_type
{
    my ($self) = @_;
    return ($self->direction == $DIRECTION_FORWARD)
        ? $self->link->type->entity0_type
        : $self->link->type->entity1_type;
}

sub source_key
{
    my ($self) = @_;
    return ($self->source_type eq 'url')
        ? $self->source->url
        : $self->source->gid;
}

sub target
{
    my ($self) = @_;
    return ($self->direction == $DIRECTION_FORWARD)
        ? $self->entity1 : $self->entity0;
}

sub target_type
{
    my ($self) = @_;
    return ($self->direction == $DIRECTION_FORWARD)
        ? $self->link->type->entity1_type
        : $self->link->type->entity0_type;
}

sub target_key
{
    my ($self) = @_;
    return ($self->target_type eq 'url')
        ? $self->target->url
        : $self->target->gid;
}

sub _join_attrs
{
    my @attrs = map { lc $_ } @{$_[0]};
    if (scalar(@attrs) > 1) {
        my $a = pop(@attrs);
        my $b = join(", ", @attrs);
        return "$b and $a";
    }
    elsif (scalar(@attrs) == 1) {
        return $attrs[0];
    }
    return '';
}

sub _build_phrase {
    my ($self) = @_;
    $self->_interpolate(
        $self->direction == $DIRECTION_FORWARD
            ? $self->link->type->link_phrase
            : $self->link->type->reverse_link_phrase
    );
}

sub _build_verbose_phrase {
    my ($self) = @_;
    $self->_interpolate($self->link->type->short_link_phrase);
}

sub _interpolate
{
    my ($self, $phrase) = @_;

    my @attrs = $self->link->all_attributes;
    my %attrs;
    foreach my $attr (@attrs) {
        my $name = lc $attr->root->name;
        my $value = lc $attr->name;
        if (exists $attrs{$name}) {
            push @{$attrs{$name}}, $value;
        }
        else {
            $attrs{$name} = [ $value ];
        }
    }

    my $replace_attrs = sub {
        my ($name, $alt) = @_;
        if (!$alt) {
            return '' unless exists $attrs{$name};
            return _join_attrs($attrs{$name});
        }
        else {
            my ($alt1, $alt2) = split /\|/, $alt;
            return $alt2 || '' unless exists $attrs{$name};
            my $attr = _join_attrs($attrs{$name});
            $alt1 =~ s/%/$attr/eg;
            return $alt1;
        }
    };
    $phrase =~ s/{(.*?)(?::(.*?))?}/$replace_attrs->($1, $2)/eg;
    MusicBrainz::Server::Validation::TrimInPlace($phrase);

    return $phrase;
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
