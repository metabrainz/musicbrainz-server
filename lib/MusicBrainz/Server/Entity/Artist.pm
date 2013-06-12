package MusicBrainz::Server::Entity::Artist;

use Moose;
use MusicBrainz::Server::Constants qw( $DARTIST_ID $VARTIST_ID $VARTIST_GID );
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
    isa => 'Maybe[Int]'
);

has 'type' => (
    is => 'rw',
    isa => 'ArtistType',
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

has 'gender_id' => (
    is => 'rw',
    isa => 'Int'
);

has 'gender' => (
    is => 'rw',
    isa => 'Gender',
);

sub gender_name
{
    my ($self) = @_;
    return $self->gender ? $self->gender->name : undef;
}

sub l_gender_name
{
    my ($self) = @_;
    return $self->gender ? $self->gender->l_name : undef;
}

has 'area_id' => (
    is => 'rw',
    isa => 'Int'
);

has 'area' => (
    is => 'rw',
    isa => 'Area'
);

has 'begin_area_id' => (
    is => 'rw',
    isa => 'Int'
);

has 'begin_area' => (
    is => 'rw',
    isa => 'Area'
);

has 'end_area_id' => (
    is => 'rw',
    isa => 'Int'
);

has 'end_area' => (
    is => 'rw',
    isa => 'Area'
);

has 'comment' => (
    is => 'rw',
    isa => 'Maybe[Str]'
);

sub is_special_purpose {
    my $self = shift;
    return ($self->id && ($self->id == $DARTIST_ID ||
                          $self->id == $VARTIST_ID))
        || ($self->gid && $self->gid eq $VARTIST_GID);
}

sub appearances {
    my $self = shift;
    my @rels = @{ $self->relationships_by_type('release', 'release_group', 'work',
                                               'recording') };

    my %groups;
    for my $rel (@rels) {
        my $phrase = $rel->link->type->name;
        $groups{ $phrase } ||= [];
        push @{ $groups{$phrase} }, $rel;
    }

    return \%groups;
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
