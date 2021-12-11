package MusicBrainz::Server::Data::Script;

use Moose;
use namespace::autoclean;
use MusicBrainz::Server::Entity::Script;

use MusicBrainz::Server::Data::Utils qw( load_subobjects );

extends 'MusicBrainz::Server::Data::Entity';
with 'MusicBrainz::Server::Data::Role::EntityCache';
with 'MusicBrainz::Server::Data::Role::SelectAll' => { order_by => ['name'] };
with 'MusicBrainz::Server::Data::Role::InsertUpdateDelete';

sub _type { 'script' }

sub _table
{
    return 'script';
}

sub _columns
{
    return 'id, iso_code, iso_number, name, frequency';
}

sub _column_mapping {
    return {
        id          => 'id',
        name        => 'name',
        iso_code    => 'iso_code',
        iso_number  => 'iso_number',
        frequency   => 'frequency',
    };
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::Script';
}

sub load
{
    my ($self, @objs) = @_;
    load_subobjects($self, 'script', @objs);
}

sub find_by_code
{
    my ($self, $code) = @_;
    return $self->_get_by_key('iso_code' => $code, transform => 'lower');
}

sub in_use {
    my ($self, $id) = @_;
    return $self->sql->select_single_value(
        'SELECT 1 FROM release WHERE script = ? LIMIT 1',
        $id);
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
