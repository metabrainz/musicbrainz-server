package MusicBrainz::Server::Report::ReleaseGroupsWithoutVACredit;
use Moose;
use MusicBrainz::Server::Constants qw( $VARTIST_ID );

with 'MusicBrainz::Server::Report::ReleaseGroupReport';

sub query {
    "
        SELECT
            rg.id AS release_group_id,
            row_number() OVER (ORDER BY rg.artist_credit, rg.name)
        FROM release_group rg
        JOIN artist_credit_name acn on acn.artist_credit = rg.artist_credit
        WHERE acn.artist = $VARTIST_ID AND acn.name != 'Various Artists'
    ";
}

sub template {
    return 'report/release_groups_without_va_credit.tt';
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

This file is part of MusicBrainz, the open internet music database.
Copyright (C) 2015 MetaBrainz Foundation
Licensed under the GPL version 2, or (at your option) any later version:
http://www.gnu.org/licenses/gpl-2.0.txt

=cut
