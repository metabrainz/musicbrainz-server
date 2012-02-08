package MusicBrainz::Server::Report::NoScript;
use Moose;

extends 'MusicBrainz::Server::Report::ReleaseReport';

sub gather_data
{
    my ($self, $writer) = @_;

    $self->gather_data_from_query($writer, "
        SELECT
            r.gid, rn.name, r.artist_credit AS artist_credit_id
        FROM release r
            JOIN release_name rn ON r.name = rn.id
        WHERE script IS NULL
        ORDER BY r.artist_credit, r.name
    ");
}

sub template
{
    return 'report/releases_without_script.tt';
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2009 Lukas Lalinsky

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut
