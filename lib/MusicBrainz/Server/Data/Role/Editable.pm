package MusicBrainz::Server::Data::Role::Editable;
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

    method 'adjust_edit_pending' => sub
    {
        my ($self, $adjust, @ids) = @_;
        my $query = "UPDATE $table SET edits_pending = numeric_larger(0, edits_pending + ?) WHERE id IN (" . placeholders(@ids) . ")";
        $self->sql->do($query, $adjust, @ids);
        if ($self->does('MusicBrainz::Server::Data::Role::EntityCache')) {
            $self->_delete_from_cache(@ids);
        }
    };

};

no Moose::Role;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Oliver Charles

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
