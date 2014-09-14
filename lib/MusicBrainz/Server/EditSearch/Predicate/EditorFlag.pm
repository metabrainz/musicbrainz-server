package MusicBrainz::Server::EditSearch::Predicate::EditorFlag;
use Moose;
use namespace::autoclean;
use feature 'switch';

extends 'MusicBrainz::Server::EditSearch::Predicate::Set';

sub combine_with_query {
    my ($self, $query) = @_;
    return unless $self->arguments;

    $query->add_where([
        "EXISTS (SELECT 1 FROM editor WHERE id = edit.editor AND privs & (" . join(" & ", map { "?::integer" } @{ $self->sql_arguments->[0] }) . ") " .
             ($self->operator eq '='  ? '!=' :
             $self->operator eq '!=' ? '=' : die 'Shouldnt get here')
         . " 0)",
        @{ $self->sql_arguments }
    ]);
}

1;
