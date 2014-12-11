package MusicBrainz::Server::Data::Role::EntityCacheBase;

use Moose::Role;
use List::MoreUtils qw( uniq );

around 'get_by_ids' => sub
{
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

after 'update' => sub
{
    my ($self, $id) = @_;
    $self->_delete_from_cache($id);
};

after 'delete' => sub
{
    my ($self, @ids) = @_;
    $self->_delete_from_cache(@ids);
};

after 'merge' => sub
{
    my ($self, @ids) = @_;
    $self->_delete_from_cache(@ids);
};

sub _delete_from_cache
{
    my ($self, @ids) = @_;

    return unless grep { defined } @ids;

    my @keys = map { $self->_id_cache_prefix . ':' . $_ } uniq grep { defined } @ids;
    my $cache = $self->c->cache($self->_id_cache_prefix);
    my $method = @keys > 1 ? 'delete_multi' : 'delete';
    $cache->$method(@keys);
}

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
