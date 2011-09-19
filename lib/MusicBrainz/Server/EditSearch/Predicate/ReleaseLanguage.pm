package MusicBrainz::Server::EditSearch::Predicate::ReleaseLanguage;
use Moose;
use namespace::autoclean;
use feature 'switch';

extends 'MusicBrainz::Server::EditSearch::Predicate::Set';

sub combine_with_query {
    my ($self, $query) = @_;
    return unless $self->arguments;

    my $join_e_idx = $query->inc_joins;
    my $edit_alias = "edit_release_$join_e_idx";
    $query->add_join("JOIN edit_release $edit_alias ON $edit_alias.edit = edit.id");

    my $join_r_idx = $query->inc_joins;
    my $release_alias = "release_$join_r_idx";
    $query->add_join("JOIN release $release_alias ON $release_alias.id = $edit_alias.release");

    $query->add_where([
        join(' ', "$release_alias.language", $self->operator,
             $self->operator eq '='  ? 'any(?)' :
             $self->operator eq '!=' ? 'all(?)' : die 'Shouldnt get here'),
        $self->sql_arguments
    ]) if $self->arguments > 0;
}

1;
