package MusicBrainz::Server::Report::ReleaseGroupsWithoutVALink;
use Moose;

with 'MusicBrainz::Server::Report::ReleaseGroupReport';

sub component_name { 'ReleaseGroupsWithoutVaLink' }

sub query {
    q{
        SELECT
            rg.id AS release_group_id,
            row_number() OVER (ORDER BY rg.artist_credit, rg.name)
        FROM release_group rg
        JOIN artist_credit_name acn ON acn.artist_credit = rg.artist_credit
        JOIN artist a ON a.id = acn.artist
        WHERE acn.name = 'Various Artists'
          AND a.name != 'Various Artists'
    };
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2015 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
