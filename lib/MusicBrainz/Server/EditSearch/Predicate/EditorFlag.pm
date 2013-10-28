package MusicBrainz::Server::EditSearch::Predicate::EditorFlag;
use Moose;
use namespace::autoclean;
use feature 'switch';

extends 'MusicBrainz::Server::EditSearch::Predicate::Set';

sub combine_with_query {
    my ($self, $query) = @_;
    return unless $self->arguments;

    my $join_e_idx = $query->inc_joins;
    my $editor_alias = "editor_$join_e_idx";
    $query->add_join("JOIN editor $editor_alias ON $editor_alias.id = edit.editor");

    $query->add_where([
        "$editor_alias.privs & (" . join(" & ", map { "?" } $self->sql_arguments) . ") != 0",
        @{ $self->sql_arguments }
    ]);
}

1;
