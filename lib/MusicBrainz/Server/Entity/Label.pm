package MusicBrainz::Server::Entity::Label;

use Moose;
use MusicBrainz::Server::Entity::PartialDate;
use MusicBrainz::Server::Entity::Types;

extends 'MusicBrainz::Server::Entity::CoreEntity';
with 'MusicBrainz::Server::Entity::Role::Taggable';
with 'MusicBrainz::Server::Entity::Role::Linkable';
with 'MusicBrainz::Server::Entity::Role::Annotation';
with 'MusicBrainz::Server::Entity::Role::LastUpdate';
with 'MusicBrainz::Server::Entity::Role::Rating';
with 'MusicBrainz::Server::Entity::Role::Age';
with 'MusicBrainz::Server::Entity::Role::IPI';
with 'MusicBrainz::Server::Entity::Role::ISNI';

has 'sort_name' => (
    is => 'rw',
    isa => 'Str'
);

has 'type_id' => (
    is => 'rw',
    isa => 'Int'
);

has 'type' => (
    is => 'rw',
    isa => 'LabelType',
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

has 'label_code' => (
    is => 'rw',
    isa => 'Int'
);

sub format_label_code
{
    my $self = shift;
    if ($self->label_code) {
        return sprintf "LC %05d", $self->label_code;
    }
    return "";
}

has 'area_id' => (
    is => 'rw',
    isa => 'Int'
);

has 'area' => (
    is => 'rw',
    isa => 'Area'
);

has 'comment' => (
    is => 'rw',
    isa => 'Str'
);

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
