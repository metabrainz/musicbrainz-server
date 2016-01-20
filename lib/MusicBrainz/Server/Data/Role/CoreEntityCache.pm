package MusicBrainz::Server::Data::Role::CoreEntityCache;

use Moose::Role;

with 'MusicBrainz::Server::Data::Role::EntityCache';

around get_by_gid => sub {
    my ($orig, $self, $gid) = @_;

    return undef
        unless defined $gid;

    my $key = $self->_id_cache_prefix . ':' . $gid;
    my $cache = $self->c->cache($self->_id_cache_prefix);
    my $id = $cache->get($key);
    my $obj;
    if (defined($id)) {
        $obj = $self->get_by_id($id);
    } else {
        $obj = $self->$orig($gid);
        if (defined($obj)) {
            $self->_add_to_cache($cache, $obj->id => $obj);
        }
    }
    return $obj;
};

around _create_cache_entries => sub {
    my ($orig, $self, $data) = @_;

    my $prefix = $self->_id_cache_prefix . ':';
    my @orig_entries = $self->$orig($data);
    my @entries = @orig_entries;
    # Only add gid entries for entities returned from $self->$orig, which
    # may be a subset of $data if any are being deleted in a concurrent
    # transaction.
    for my $entry (@orig_entries) {
        my $entity = $entry->[1];
        push @entries, [$prefix . $entity->gid, $entity->id];
    }
    @entries;
};

1;

=head1 COPYRIGHT

Copyright (C) 2009 Lukas Lalinsky
Copyright (C) 2016 MetaBrainz Foundation

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
