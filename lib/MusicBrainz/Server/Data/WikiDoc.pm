package MusicBrainz::Server::Data::WikiDoc;
use Moose;
use namespace::autoclean;

use Carp;
use Readonly;
use HTML::TreeBuilder::XPath;
use MusicBrainz::Server::Entity::WikiDocPage;
use URI::Escape qw( uri_unescape );
use Encode qw( decode );

with 'MusicBrainz::Server::Data::Role::Context';

Readonly my $WIKI_CACHE_TIMEOUT => 60 * 60;
Readonly my $WIKI_IMAGE_PREFIX => '/-/images';

sub _fix_html_links
{
    my ($self, $node, $index) = @_;

    my $server      = DBDefs::WEB_SERVER;
    my $wiki_server = DBDefs::WIKITRANS_SERVER;

    my $class = $node->attr('class') || "";

    # Remove the title attribute from all links
    $node->attr('title', undef);

    # if this is not a link to _our_ wikidocs server, don't mess with it.
    return if ($class =~ m/external/ || $class =~ m/extiw/);

    my $href = $node->attr('href') || "";

    # Remove broken links & links to images in the wiki
    if ($href =~ m,^https?://$wiki_server/(File|Image):, || $class =~ m/new/)
    {
        $node->replace_with ($node->content_list);
    }
    # if this is not a link to the wikidocs server, don't mess with it.
    elsif ($href =~ m,^https?://$wiki_server,)
    {
        $href =~ s,^https?://$wiki_server/?,//$server/doc/,;
        $node->attr('href', $href);
    }
    elsif ($href =~ m,^$WIKI_IMAGE_PREFIX,) {
        $href =~ s,$WIKI_IMAGE_PREFIX?,//$wiki_server$WIKI_IMAGE_PREFIX,;
        $node->attr('href', $href);
    }
}

sub _fix_html_markup
{
    my ($self, $content, $index) = @_;

    my $wiki_server = DBDefs::WIKITRANS_SERVER;
    my $tree = HTML::TreeBuilder::XPath->new;

    $tree->parse_content ("<html><body>".$content."</body></html>");
    for my $node ($tree->findnodes (
                      '//span[contains(@class, "editsection")]')->get_nodelist)
    {
        $node->delete();
    }

    for my $node ($tree->findnodes ('//a')->get_nodelist)
    {
        $self->_fix_html_links ($node, $index);
    }

    for my $node ($tree->findnodes ('//img')->get_nodelist)
    {
        my $src = $node->attr('src') || "";
        $node->attr('src', $src) if ($src =~ s,$WIKI_IMAGE_PREFIX,//$wiki_server$WIKI_IMAGE_PREFIX,);
    }

    for my $node ($tree->findnodes ('//table')->get_nodelist)
    {
        my $class = $node->attr('class') || "";

        # Special cases where we don't want this class added
        next if ($class =~ /(\btoc\b|\btbl\b)/);

        $node->attr('class', 'wikitable ' . $class);
    }

    $content = $tree->as_HTML;

    # Obfuscate email addresses
    $content =~ s/(\w+)\@(\w+)/$1&#x0040;$2/g;
    $content =~ s/mailto:/mailto&#x3a;/g;

    return $content;
}

sub _create_page
{
    my ($self, $id, $version, $content, $index) = @_;

    my $title = $id;
    $title =~ s/_/ /g;
    # Create hierarchy for displaying in the h1
    my @hierarchy = split('/',$title);

    # Format nicely for <title>
    $title =~ s,/, / ,g;

    $content = $self->_fix_html_markup($content, $index);

    my %args = ( title => $title, hierarchy => \@hierarchy, content  => $content );
    if (defined $version) {
        $args{version} = $version;
    }
    return MusicBrainz::Server::Entity::WikiDocPage->new(%args);
}

sub _load_page
{
    my ($self, $id, $version, $index) = @_;

    return MusicBrainz::Server::Entity::WikiDocPage->new({ canonical => "MusicBrainz_Documentation" })
        if ($id eq "");

    my $doc_url = sprintf "http://%s/%s?action=render&redirect=no", &DBDefs::WIKITRANS_SERVER, $id;
    if (defined $version) {
        $doc_url .= "&oldid=$version";
    }

    my $response = $self->c->lwp->get($doc_url);

    if (!$response->is_success) {
        if ($response->is_redirect && $response->header("Location") =~ /https?:\/\/(.*?)\/(.*)$/) {
            return $self->get_page(uri_unescape($2));
        }
        return undef;
    }

    my $content = decode "utf-8", $response->content;
    if ($content =~ /<title>Error/s) {
        return undef;
    }

    if ($content =~ /<div class="noarticletext">/s) {
        return undef;
    }

    if ($content =~ /<span class="redirectText"><a href="https?:\/\/.*?\/(.*?)"/) {
        return MusicBrainz::Server::Entity::WikiDocPage->new({ canonical => uri_unescape($1) });
    }

    return $self->_create_page($id, $version, $content, $index);
}

sub get_version
{
    my ($self, $id) = @_;

    my $doc_url = sprintf "http://%s/?title=%s", &DBDefs::WIKITRANS_SERVER, $id;
    my $response = $self->c->lwp->get($doc_url);

    my $content = $response->decoded_content;

    my $ret = { canonical => $id, version => undef };

    if ($content =~ /var wgPageName = "(.*)"/)
    {
        $ret->{canonical} = $1;
    }

    if ($content =~ /var wgCurRevisionId = "([0-9]*)"/)
    {
        $ret->{version} = $1;
    }

    return $ret;
}

sub get_page
{
    my ($self, $id, $version, $index) = @_;

    my $prefix = 'wikidoc';
    my $cache = $self->c->cache($prefix);
    my $cache_key = defined $version ? "$prefix:$id:$version" : "$prefix:$id:current";

    my $page = $cache->get($cache_key);
    return $page
        if defined $page;

    $page = $self->_load_page($id, $version, $index) or return undef;

    $cache->set($cache_key, $page, $WIKI_CACHE_TIMEOUT);

    return $page;
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
