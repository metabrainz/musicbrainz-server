package MusicBrainz::Server::Data::Role::OptionsTree;
use Moose::Role;
use namespace::autoclean;

with 'MusicBrainz::Server::Data::Role::Context';
with 'MusicBrainz::Server::Data::Role::SelectAll';

sub get_tree {
    my ($self, $filter) = @_;

    my @objects;

    $filter ||= sub { return 1 };

    my %id_to_obj = map {
        my $obj = $_;
        push @objects, $obj;
        $obj->id => $obj;
    } grep {
        $filter->($_);
    } $self->get_all;

    my $root = $self->_entity_class->new;

    foreach my $obj (@objects) {
        my $parent = $obj->parent_id ? $id_to_obj{$obj->parent_id} : $root;
        $parent->add_child($obj);
    }

    return $root;
}

no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2014 MetaBrainz Foundation

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
