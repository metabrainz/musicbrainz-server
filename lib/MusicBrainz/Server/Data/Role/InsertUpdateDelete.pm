package MusicBrainz::Server::Data::Role::InsertUpdateDelete;
use Moose::Role;
use namespace::autoclean;

requires '_entity_class';
requires '_column_mapping';
requires '_id_column';
requires '_table';
requires 'sql';

sub insert
{
    my ($self, @objs) = @_;

    my $class = $self->_entity_class;
    Class::MOP::load_class($class);

    my %map = %{ $self->_column_mapping };
    my @ret;
    for my $obj (@objs)
    {
        my %row = map { ($map{$_} || $_) => $obj->{$_} } keys %$obj;
        my $id = $self->sql->insert_row($self->_table, \%row, $self->_id_column);
        push @ret, $class->new( $self->_id_column => $id, %$obj);
    }

    return wantarray ? @ret : $ret[0];
}

sub update
{
    my ($self, $id, $obj) = @_;

    my %map = %{ $self->_column_mapping };
    my %row = map { ($map{$_} || $_) => $obj->{$_} } keys %$obj;
    $self->sql->update_row($self->_table, \%row, { $self->_id_column => $id });
}

sub delete
{
    my ($self, $id) = @_;

    $self->sql->delete_row($self->_table, { $self->_id_column => $id });
}

1;
