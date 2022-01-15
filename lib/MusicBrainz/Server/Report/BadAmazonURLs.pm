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
            url !~ '^https?://www\.amazon\.(ae|at|com\.au|com\.br|ca|cn|com|de|es|fr|in|it|jp|co\.jp|com\.mx|nl|pl|se|sg|com\.tr|co\.uk)/gp/product/[0-9A-Z]{10}$' AND
            url !~ '^https?://music\.amazon\.(ae|at|com\.au|com\.br|ca|cn|com|de|es|fr|in|it|jp|co\.jp|com\.mx|nl|pl|se|sg|com\.tr|co\.uk)' 
    };
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 MetaBrainz Foundation
Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
