package MusicBrainz::Server::Report::FilterForEditor::ArtistCreditID;
use Moose::Role;

with 'MusicBrainz::Server::Report::FilterForEditor';

sub filter_sql {
    my ($self, $editor_id) = @_;

    my $filter_query = <<~'EOSQL';
        JOIN artist_credit_name ON artist_credit_id = artist_credit_name.artist_credit
        JOIN editor_subscribe_artist esa ON esa.artist = artist_credit_name.artist
        WHERE esa.editor = ?
        EOSQL

    return ($filter_query, $editor_id);
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2021 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
