package MusicBrainz::Server::Data::Role::GIDEntityCache;

use Moose::Role;
use namespace::autoclean;
use Scalar::Util qw( blessed );

with 'MusicBrainz::Server::Data::Role::EntityCache';

around get_by_gid => sub {
    my ($orig, $self, $gid) = @_;

    return undef
        unless defined $gid;

    my $key = $self->_cache_prefix . $gid;
    my $cache = $self->c->cache($self->_type);
    my $id = $cache->get($key);
    my $obj;
    if (defined($id)) {
        $obj = $self->get_by_id($id);
    } else {
        $obj = $self->$orig($gid);
        if (defined($obj)) {
            $id = $obj->id;
            $self->_add_to_cache(
                $cache,
                { $id => $obj, $gid => $id, $obj->gid => $id },
                [$id, $gid, $obj->gid],
            );
        }
    }
    return $obj;
};

around _create_cache_entries => sub {
    my ($orig, $self, $data, $ids) = @_;

    my $prefix = $self->_cache_prefix;
    my @entries = $self->$orig($data, $ids);
    my @entity_entries = grep {
        my $value = $_->[1];
        blessed $value &&
            $value->does('MusicBrainz::Server::Entity::Role::GID')
    } @entries;
    for my $entry (@entity_entries) {
        my $entity = $entry->[1];
        push @entries, [$prefix . $entity->gid, $entity->id];
    }
    @entries;
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky
Copyright (C) 2016 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
