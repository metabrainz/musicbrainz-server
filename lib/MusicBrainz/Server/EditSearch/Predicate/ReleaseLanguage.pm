package MusicBrainz::Server::EditSearch::Predicate::ReleaseLanguage;
use Moose;
use namespace::autoclean;

extends 'MusicBrainz::Server::EditSearch::Predicate::Set';

sub combine_with_query {
    my ($self, $query) = @_;
    return unless $self->arguments;

    $query->add_where([
        'EXISTS (SELECT 1 FROM edit_release A JOIN release B ON A.release = B.id WHERE A.edit = edit.id AND ' .
        join(' ', "B.language", $self->operator,
             $self->operator eq '='  ? 'any(?)' :
             $self->operator eq '!=' ? 'all(?)' : die q(Shouldn't get here)) . ')',
        $self->sql_arguments
    ]) if $self->arguments > 0;
}

1;
