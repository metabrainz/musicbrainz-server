package MusicBrainz::Server::Data::Role::InsertUpdateDelete;
use Moose::Role;
use Class::Load qw( load_class );
use MusicBrainz::Server::Data::Utils qw( generate_gid hash_to_row );
use namespace::autoclean;

requires '_entity_class';
requires '_column_mapping';
requires '_id_column';
requires '_table';
requires 'sql';

## XXX HACK - See MB::S::Data::Role::Merge

sub insert {}
around 'insert' => sub {
    my ($orig, $self, @objs) = @_;

    my $class = $self->_entity_class;
    load_class($class);

    my $map = { reverse %{ $self->_column_mapping } };
    my @ret;
    for my $obj (@objs) {
        my $row = hash_to_row($obj, $map);
        $row->{gid} = generate_gid() if $class->can('gid') && !$row->{gid};
        my $id = $self->sql->insert_row($self->_table, $row, $self->_id_column);
        push @ret, $class->new($self->_id_column => $id, %$obj);
    }

    return wantarray ? @ret : $ret[0];
};

sub update {}
around 'update' => sub {
    my ($orig, $self, $id, $obj) = @_;

    my $row = hash_to_row($obj, { reverse %{ $self->_column_mapping } });
    if (%$row) {
        $self->sql->update_row($self->_table, $row, { $self->_id_column => $id });
    }
};

sub delete {}
around 'delete' => sub {
    my ($orig, $self, $id) = @_;

    $self->sql->delete_row($self->_table, { $self->_id_column => $id });
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
