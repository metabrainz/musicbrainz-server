package MusicBrainz::Server::Sitemap::Utils;

use base 'Exporter';
use MusicBrainz::Server::Data::Utils qw( non_empty );
use MusicBrainz::Server::Validation qw( encode_entities );
use List::AllUtils qw( sort_by );
use Readonly;

=head1 SYNOPSIS

Utility methods for building sitemap files.

WWW::Sitemap::XML is not used for writing anything because it is prohibitively
slow.

Additionally, WWW::Sitemap::XML::load regularly produces non-sensical parse
errors for no apparent reason; a typical example looks something like:

/home/musicbrainz/musicbrainz-server/root/static/sitemaps/sitemap-release_group-1-aliases-incremental.xml.gz:2: parser error : expected '>'
3b85-b773-c2da5179586b/aliases</loc><lastmod>2015-10-06T23:41:05.157808Z</lastmo
                                                                               ^

Upon inspection, there is no such error in the file, and other tools load
the file just fine. This happens frequently, but not consistently. The module
versions are:

       libwww-sitemap-xml-perl 1.121160-3~trusty1
       libxml-libxml-perl      2.0108+dfsg-1ubuntu0.1

So, we're writing the files by hand, which allows for other optimizations, too,
e.g. generating deterministic XML output to make hash comparisons easier.

=cut

our @EXPORT_OK = qw(
    serialize_sitemap
    serialize_sitemap_index
);

Readonly our $SITEMAP_HEADER => <<'EOXML';
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd">
EOXML

Readonly our $SITEMAP_FOOTER => <<'EOXML';
</urlset>
EOXML

Readonly our $SITEMAP_INDEX_HEADER => <<'EOXML';
<?xml version="1.0" encoding="UTF-8"?>
<sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"
              xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
              xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/siteindex.xsd">
EOXML

Readonly our $SITEMAP_INDEX_FOOTER => <<'EOXML';
</sitemapindex>
EOXML

sub _serialize_list {
    my ($container_element_name, @items) = @_;

    my $data = '';

    for my $item (@items) {
        $data .= "<$container_element_name>";
        for my $key (sort keys %$item) {
            my $text = $item->{$key};
            if (non_empty($text)) {
                $data .= "<$key>" . encode_entities($item->{$key}) . "</$key>";
            }
        }
        $data .= "</$container_element_name>";
    }

    $data;
}

=sub serialize_sitemap

Serializes the list of C<urls> to an XML string, returning a scalar ref to it.

=cut

sub serialize_sitemap {
    my (@urls) = @_;

    my $data = $SITEMAP_HEADER;
    $data .= _serialize_list('url', sort_by { $_->{loc} } @urls);
    $data .= $SITEMAP_FOOTER;
    \$data;
}

=sub serialize_sitemap_index

Serializes the list of C<sitemaps> to an XML string, returning a scalar ref to
it. Each sitemap is a hash ref containing "loc" and "lastmod" keys.

=cut

sub serialize_sitemap_index {
    my (@sitemaps) = @_;

    my $data = $SITEMAP_INDEX_HEADER;
    $data .= _serialize_list('sitemap', sort_by { $_->{loc} } @sitemaps);
    $data .= $SITEMAP_INDEX_FOOTER;
    \$data;
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2015 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
