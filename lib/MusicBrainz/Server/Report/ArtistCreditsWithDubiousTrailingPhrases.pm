package MusicBrainz::Server::Report::ArtistCreditsWithDubiousTrailingPhrases;
use Moose;

with 'MusicBrainz::Server::Report::ArtistCreditReport',
     'MusicBrainz::Server::Report::FilterForEditor::ArtistCreditID';

sub query {<<~'SQL'}
    SELECT ac.id AS artist_credit_id, ac.name,
           row_number() OVER (ORDER BY ac.id)
    FROM artist_credit ac
    JOIN artist_credit_name acn ON acn.artist_credit = ac.id
    WHERE acn.position = (ac.artist_count - 1)
    AND acn.join_phrase ~* '(?:ft\.?|feat\.?|[;:,])\s*$'
    SQL

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2021 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
