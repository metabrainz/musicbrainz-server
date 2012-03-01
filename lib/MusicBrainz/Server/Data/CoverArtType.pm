package MusicBrainz::Server::Data::CoverArtType;

use Moose;
use namespace::autoclean;
use MusicBrainz::Server::Entity::CoverArtType;
use MusicBrainz::Server::Data::Utils qw( load_subobjects );

extends 'MusicBrainz::Server::Data::Entity';
with 'MusicBrainz::Server::Data::Role::EntityCache' => { prefix => 'cat' };
with 'MusicBrainz::Server::Data::Role::SelectAll';

sub _table
{
    return 'cover_art_archive.art_type';
}

sub _columns
{
    return 'id, name';
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::CoverArtType';
}

sub load
{
    my ($self, @objs) = @_;
    load_subobjects($self, 'type', @objs);
}

sub get_by_name
{
    my ($self, @names) = @_;

    my %types_by_name = map { $_->name => $_ } $self->get_all ();

    return map { $types_by_name{$_} } @names;
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
