package MusicBrainz::Server::Report::PlacesWithoutCoordinates;
use Moose;

with 'MusicBrainz::Server::Report::PlaceReport';

sub query {
    q{
      SELECT DISTINCT
        id AS place_id,
        row_number() OVER (ORDER BY name, last_updated)
      FROM place
      WHERE coordinates IS NULL
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2018 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
