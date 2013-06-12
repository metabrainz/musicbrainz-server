package MusicBrainz::Server::Entity::Relationship;

use Moose;
use Readonly;
use MusicBrainz::Server::Entity::Types;
use MusicBrainz::Server::Validation qw( trim_in_place );
use MusicBrainz::Server::Translation qw( l );
use MusicBrainz::Server::Data::Relationship;

use overload '<=>' => \&_cmp, fallback => 1;

Readonly our $DIRECTION_FORWARD  => 1;
Readonly our $DIRECTION_BACKWARD => 2;

extends 'MusicBrainz::Server::Entity';
with  'MusicBrainz::Server::Entity::Role::Editable';
with  'MusicBrainz::Server::Entity::Role::LastUpdate';

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

has '_phrase' => (
    is => 'ro',
    builder => '_build_phrase',
    lazy => 1
);

has '_verbose_phrase' => (
    is => 'ro',
    builder => '_build_verbose_phrase',
    lazy => 1
);

sub editor_can_edit
{
    my ($self, $editor) = @_;
    return MusicBrainz::Server::Data::Relationship->editor_can_edit($editor,
        $self->link->type->entity0_type, $self->link->type->entity1_type);
}

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

sub phrase
{
    my ($self) = @_;
    return $self->_phrase->[0];
}

sub extra_phrase_attributes
{
    my ($self) = @_;
    return $self->_phrase->[1];
}

sub verbose_phrase
{
    my ($self) = @_;
    return $self->_verbose_phrase->[0];
}

sub extra_verbose_phrase_attributes
{
    my ($self) = @_;
    return $self->_verbose_phrase->[1];
}

sub _join_attrs
{
    my @attrs = map { $_ } @{$_[0]};
    if (scalar(@attrs) > 1) {
        my $a = pop(@attrs);
        my $b = join(l(", "), @attrs);
        return l("{b} and {a}", {b => $b, a => $a});
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
            ? $self->link->type->l_link_phrase()
            : $self->link->type->l_reverse_link_phrase()
    );
}

sub _build_verbose_phrase {
    my ($self) = @_;
    $self->_interpolate($self->link->type->long_link_phrase);
}

sub _interpolate
{
    my ($self, $phrase) = @_;

    my @attrs = $self->link->all_attributes;
    my %attrs;
    foreach my $attr (@attrs) {
        my $name = lc $attr->root->name;
        my $value = $attr->l_name();
        if (exists $attrs{$name}) {
            push @{$attrs{$name}}, $value;
        }
        else {
            $attrs{$name} = [ $value ];
        }
    }
    my %extra_attrs = %attrs;

    my $replace_attrs = sub {
        my ($name, $alt) = @_;
        delete $extra_attrs{$name};
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
    $phrase =~ s/{(.*?)(?::(.*?))?}/$replace_attrs->(lc $1, $2)/eg;
    trim_in_place($phrase);

    my @extra_attrs = map { @$_ } values %extra_attrs;
    return [ $phrase, _join_attrs(\@extra_attrs) ];
}

sub _cmp {
    my ($a, $b) = @_;

    my $a_sortname = $a->target->can('sort_name')
        ? $a->target->sort_name
        : $a->target->name;
    my $b_sortname = $b->target->can('sort_name')
        ? $b->target->sort_name
        : $b->target->name;
    $a->link->begin_date        <=> $b->link->begin_date ||
    $a->link->end_date          <=> $b->link->end_date   ||
    $a->link->type->child_order <=> $b->link->type->child_order ||
    $a_sortname cmp $b_sortname;
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
