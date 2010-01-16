package MusicBrainz::Server::Data::Role::CoreEntityCache;

use MooseX::Role::Parameterized;

parameter 'prefix' => (
    isa => 'Str',
    required => 1,
);

role {

    my $params = shift;

    with 'MusicBrainz::Server::Data::Role::EntityCacheBase';

    method '_id_cache_prefix' => sub { $params->{prefix} };

    method '_add_to_cache' => sub
    {
        my ($self, $cache, %data) = @_;
        my @tmp;
        foreach my $id (keys %data) {
            my $obj = $data{$id};
            my $key = $self->_id_cache_prefix . ':' . $id;
            push @tmp, [$key, $obj];
            $key = $self->_id_cache_prefix . ':' . $obj->gid;
            push @tmp, [$key, $id];
        }
        $cache->set_multi(@tmp);
    };

    around 'get_by_gid' => sub
    {
        my ($orig, $self, $gid) = @_;

        return undef
            unless defined $gid;

        my $key = $self->_id_cache_prefix . ':' . $gid;
        my $cache = $self->c->cache($self->_id_cache_prefix);
        my $id = $cache->get($key);
        my $obj;
        if (defined($id)) {
            $obj = $self->get_by_id($id);
        }
        else {
            $obj = $self->$orig($gid);
            if (defined($obj)) {
                $cache->set($key, $obj->id);
                $key = $self->_id_cache_prefix . ':' . $obj->id;
                $cache->set($key, $obj);
            }
        }
        return $obj;
    };

};

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
