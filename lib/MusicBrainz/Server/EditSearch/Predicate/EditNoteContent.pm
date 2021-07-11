package MusicBrainz::Server::EditSearch::Predicate::EditNoteContent;
use Moose;

with 'MusicBrainz::Server::EditSearch::Predicate';

sub operator_cardinality_map {
  return (
      'includes' => undef,
  )
}

sub combine_with_query {
    my ($self, $query) = @_;

    my @patterns = map {
      $_ =~ s/\\/\\\\/g;
      $_ =~ s/_/\\_/g;
      $_ =~ s/%/\\%/g;
      '%' . $_ . '%'
    } @{ $self->sql_arguments };

    $query->add_where([
        'EXISTS (
          SELECT TRUE FROM edit_note
          WHERE edit_note.text ILIKE ?
            AND edit_note.edit = edit.id
        )',
        \@patterns,
    ]);
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2015-2017 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
