package MusicBrainz::Server::Data::Role::EntityCache;

use DBDefs;
use Moose::Role;
use List::MoreUtils qw( uniq );
use MusicBrainz::Server::Constants qw( %ENTITIES );
use Scalar::Util qw( looks_like_number );

requires '_type';

sub _id_cache_info {
    my ($self, $prop) = @_;

    my $type = $self->_type;
    if ($type && (my $entity_properties = $ENTITIES{$type})) {
        if (exists $entity_properties->{cache}) {
            return $entity_properties->{cache}{$prop};
        }
    }
}

has _id_cache_id => (
    is => 'ro',
    isa => 'Maybe[Str]',
    lazy => 1,
    default => sub { shift->_id_cache_info('id') },
);

has _id_cache_prefix => (
    is => 'ro',
    isa => 'Maybe[Str]',
    lazy => 1,
    default => sub { shift->_id_cache_info('prefix') },
);

around get_by_ids => sub {
    my ($orig, $self, @ids) = @_;
    return {} unless grep { defined && $_ } @ids;
    my %ids = map { $_ => 1 } @ids;
    my @keys = map { $self->_id_cache_prefix . ':' . $_ } keys %ids;
    my $cache = $self->c->cache($self->_id_cache_prefix);
    my %data = %{$cache->get_multi(@keys)};
    my %result;
    foreach my $key (keys %data) {
        my @key = split /:/, $key;
        my $id = $key[1];
        $result{$id} = $data{$key};
        delete $ids{$id};
    }
    if (%ids) {
        my $data = $self->$orig(keys %ids) || {};
        foreach my $id (keys %$data) {
            $result{$id} = $data->{$id};
        }
        $self->_add_to_cache($cache, %$data);
    }
    return \%result;
};

after update => sub {
    my ($self, $id) = @_;
    $self->_delete_from_cache($id);
};

after delete => sub {
    my ($self, @ids) = @_;
    $self->_delete_from_cache(@ids);
};

after merge => sub {
    my ($self, @ids) = @_;
    $self->_delete_from_cache(@ids);
};

sub _create_cache_entries {
    my ($self, $data) = @_;

    my $cache_id = $self->_id_cache_id;
    my $cache_prefix = $self->_id_cache_prefix . ':';
    my @entries;
    for my $id (keys %{$data}) {
        # MBS-7241
        my $got_lock = $self->c->sql->select_single_value(
            'SELECT pg_try_advisory_xact_lock(?, ?)',
            $cache_id,
            $id,
        );
        if ($got_lock) {
            push @entries, [$cache_prefix . $id, $data->{$id}, DBDefs->ENTITY_CACHE_TTL];
        }
    }
    @entries;
}

sub _add_to_cache {
    my ($self, $cache, %data) = @_;

    my @entries = $self->_create_cache_entries(\%data);
    $cache->set_multi(@entries) if @entries;
}

sub _delete_from_cache {
    my ($self, @ids) = @_;

    @ids = uniq grep { defined } @ids;
    return unless @ids;

    my $cache_id = $self->_id_cache_id;
    my $cache_prefix = $self->_id_cache_prefix . ':';
    my @keys;

    for my $id (@ids) {
        if (looks_like_number($id)) {
            # MBS-7241
            $self->c->sql->do('SELECT pg_advisory_xact_lock(?, ?)', $cache_id, $id);
        }
        push @keys, $cache_prefix . $id;
    }

    my $cache = $self->c->cache($self->_id_cache_prefix);
    my $method = @keys > 1 ? 'delete_multi' : 'delete';
    $cache->$method(@keys);
}

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
