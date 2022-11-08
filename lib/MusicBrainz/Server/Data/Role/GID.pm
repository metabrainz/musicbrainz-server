package MusicBrainz::Server::Data::Role::GID;

use Moose::Role;
use namespace::autoclean;

use MusicBrainz::Server::Data::Utils qw( generate_gid );

requires '_hash_to_row', '_main_table';
requires 'sql';

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

no Moose::Role;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009,2011 Lukas Lalinsky
Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
