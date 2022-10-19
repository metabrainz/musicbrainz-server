package MusicBrainz::Server::Data::CoreEntity;

use Moose;
use namespace::autoclean;
use MusicBrainz::Server::Constants qw( %ENTITIES );
use MusicBrainz::Server::Data::Utils qw( generate_gid );
use Sql;

extends 'MusicBrainz::Server::Data::Entity';
with 'MusicBrainz::Server::Data::Role::GetByGID';
with 'MusicBrainz::Server::Data::Role::GIDRedirect';
with 'MusicBrainz::Server::Data::Role::Name';

sub _main_table {
    my $type = shift->_type;
    return $ENTITIES{$type}{table} // $type;
}

# Override this for joins etc. if necessary.
sub _table { shift->_main_table }

sub _entity_class { 'MusicBrainz::Server::Entity::' . $ENTITIES{shift->_type}{model} }

sub insert {
    my ($self, @entities) = @_;

    my $extra_data = $self->_insert_hook_prepare(\@entities);

    my @created;
    for my $entity (@entities) {
        my $row = $self->_insert_hook_make_row($entity, $extra_data);
        $row->{gid} = $entity->{gid} || generate_gid();

        my $created = {
            id => $self->sql->insert_row($self->_main_table, $row, 'id'),
            gid => $row->{gid},
        };

        $self->_insert_hook_after_each($created, $entity, $extra_data);

        push @created, $created;
    }

    $self->_insert_hook_after(\@created, $extra_data);
    return @entities > 1 ? @created : $created[0];
}

sub _insert_hook_prepare { {} }

sub _insert_hook_make_row {
    my ($self, $entity) = @_;
    return $self->_hash_to_row($entity);
}

sub _insert_hook_after_each { }

sub _insert_hook_after { }

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 NAME

MusicBrainz::Server::Data::CoreEntity

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009,2011 Lukas Lalinsky
Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
