package MusicBrainz::Server::Data::SelectAll;
use MooseX::Role::Parameterized;

use MusicBrainz::Server::Data::Utils qw( query_to_list );

parameter 'order_by' => (
    isa => 'ArrayRef',
    default => sub { ['id'] }
);

role
{
    requires '_columns', '_table', '_dbh', '_new_from_row';

    my $p = shift;
    method 'get_all' => sub
    {
        my $self = shift;
        my $query = "SELECT " . $self->_columns . 
                    " FROM " . $self->_table .
                    " ORDER BY " . (join ", ", @{ $p->order_by });
        return query_to_list($self->c, sub { $self->_new_from_row(shift) }, $query);
    };
};

no Moose::Role;
1;
