package MusicBrainz::Server::EditSearch::Predicate::ArtistCountry;
use Moose;
use namespace::autoclean;
use feature 'switch';

extends 'MusicBrainz::Server::EditSearch::Predicate::Set';

sub combine_with_query {
    my ($self, $query) = @_;
    return unless $self->arguments;

    my $join_e_idx = $query->inc_joins;
    my $edit_alias = "edit_artist_$join_e_idx";
    $query->add_join("JOIN edit_artist $edit_alias ON $edit_alias.edit = edit.id");

    my $join_r_idx = $query->inc_joins;
    my $artist_alias = "artist_$join_r_idx";
    $query->add_join("JOIN artist $artist_alias ON $artist_alias.id = $edit_alias.artist");

    $query->add_where([
        join(' ', "$artist_alias.country", $self->operator,
             $self->operator eq '='  ? 'any(?)' :
             $self->operator eq '!=' ? 'all(?)' : die 'Shouldnt get here'),
        $self->sql_arguments
    ]) if $self->arguments > 0;
}

1;
