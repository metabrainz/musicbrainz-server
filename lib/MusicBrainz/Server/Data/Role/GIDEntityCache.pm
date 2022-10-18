package MusicBrainz::Server::Data::Role::GIDEntityCache;

use Moose::Role;
use namespace::autoclean;

with 'MusicBrainz::Server::Data::Role::EntityCache';

around get_by_gid => sub {
    my ($orig, $self, $gid) = @_;

    return undef
        unless defined $gid;

    my $key = $self->_type . ':' . $gid;
    my $cache = $self->c->cache($self->_type);
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

    my $prefix = $self->_type . ':';
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

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky
Copyright (C) 2016 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
