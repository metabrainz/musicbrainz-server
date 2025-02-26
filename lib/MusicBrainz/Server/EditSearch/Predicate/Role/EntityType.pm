package MusicBrainz::Server::EditSearch::Predicate::Role::EntityType;
use MooseX::Role::Parameterized;
use namespace::autoclean;

parameter 'type' => (
    isa => 'Str',
    required => 1,
);

role {
    my $params = shift;
    my $type = $params->type;

    requires 'arguments';

    method 'combine_with_query' => sub
    {
        my ($self, $query) = @_;
        return unless $self->arguments;

        $query->add_where([
            "EXISTS (SELECT 1 FROM edit_$type A JOIN $type B ON A.$type = B.id WHERE A.edit = edit.id AND " .
            join(' ', 'B.type', $self->operator,
                $self->operator eq '='  ? 'any(?)' :
                $self->operator eq '!=' ? 'all(?)' : die q(Shouldn't get here)) . ')',
            $self->sql_arguments,
        ]) if $self->arguments > 0;
   };

};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2025 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
