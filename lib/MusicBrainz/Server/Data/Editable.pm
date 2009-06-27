package MusicBrainz::Server::Data::Editable;
use MooseX::Role::Parameterized;

use MusicBrainz::Server::Data::Utils qw( placeholders );
use Sql;

parameter 'table' => (
    isa => 'Str',
    required => 1
);

role {
    my $params = shift;
    my $table = $params->table;

    requires '_dbh';

    method 'inc_edits_pending' => sub
    {
        my ($self, @ids) = @_;
        my $sql = Sql->new($self->_dbh);
        my $query = "UPDATE $table SET editpending = editpending + 1 WHERE id IN (" . placeholders(@ids) . ")";
        $sql->Do($query, @ids);
    };

    method 'dec_edits_pending' => sub
    {
        my ($self, @ids) = @_;
        my $sql = Sql->new($self->_dbh);
        my $query = "UPDATE $table SET editpending = editpending - 1 WHERE id IN (" . placeholders(@ids) . ")";
        $sql->Do($query, @ids);
    };
};

no Moose::Role;
1;
