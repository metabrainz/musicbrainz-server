package MusicBrainz::Server::Report::BadAmazonURLs;
use Moose;

with 'MusicBrainz::Server::Report::ReleaseReport',
     'MusicBrainz::Server::Report::URLReport',
     'MusicBrainz::Server::Report::FilterForEditor::ReleaseID';

sub table { 'bad_amazon_urls' }
sub component_name { 'BadAmazonUrls' }

sub query
{
    q{
        SELECT
            url.id AS url_id, r.id AS release_id,
            row_number() OVER (ORDER BY url.id DESC)
        FROM
            l_release_url lru
            JOIN url ON lru.entity1 = url.id
            JOIN release r ON lru.entity0 = r.id
        WHERE
            url ~ 'amazon\.' AND
            url !~ '^https?://www\.amazon\.(ae|at|com\.au|com\.br|ca|cn|com|de|es|fr|in|it|jp|co\.jp|com\.mx|nl|se|sg|com\.tr|co\.uk)/gp/product/[0-9A-Z]{10}$' AND
            url !~ '^https?://music\.amazon\.(ae|at|com\.au|com\.br|ca|cn|com|de|es|fr|in|it|jp|co\.jp|com\.mx|nl|se|sg|com\.tr|co\.uk)' 
    };
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2009 MetaBrainz Foundation
Copyright (C) 2012 MetaBrainz Foundation

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
