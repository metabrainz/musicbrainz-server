package MusicBrainz::Server::Report::BadAmazonURLs;
use Moose;

extends 'MusicBrainz::Server::Report::ReleaseReport';

sub gather_data
{
    my ($self, $writer) = @_;

    $self->gather_data_from_query($writer, "
        SELECT
            url, url.gid AS url_gid, r.gid AS release_gid, rn.name, r.artist_credit AS artist_credit_id
        FROM
            l_release_url lru
            JOIN url ON lru.entity1 = url.id 
            JOIN release r ON lru.entity0 = r.id
            JOIN release_name rn ON r.name = rn.id
        WHERE
            url ~ E'amazon\\\\.' AND
            url !~ E'^http://www\\\\.amazon\\\\.(com|ca|cn|de|es|fr|it|co\\\\.(jp|uk))/gp/product/[0-9A-Z]{10}\$'
        ORDER BY url.id DESC
    ");
}

sub template
{
    return 'report/bad_amazon_urls.tt';
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2009 MetaBrainz Foundation

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
